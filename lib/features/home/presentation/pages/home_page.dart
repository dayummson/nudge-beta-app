import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import "../../widgets/header.dart";
import "../../widgets/floating_action_buttons.dart";
import "../../widgets/categories_list.dart";
import "../../widgets/transactions_list.dart";
import '../providers/search_input_provider.dart';
import '../providers/selected_category_provider.dart';
import '../providers/search_enabled_provider.dart';
import '../providers/transaction_type_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool isExpense = true;
  final _db = AppDatabase();

  // Key and measured height for the header so content padding can match the
  // actual header size (makes the header hug its content and avoids hard
  // coding heights that cause overflow).
  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 110.0;
  // Debug mode: 0 = normal, 1 = force-high-blur, 2 = visible-scrim (debug color)
  int _debugMode = 0;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // Cache both lists to avoid flicker when toggling
  List<Expense> _expenses = [];
  List<Income> _incomes = [];

  // Flag to track initial load
  bool _initialLoadDone = false;

  // Current selected room ID
  String? _selectedRoomId;

  // Month/year filter (null means "All time")
  int? _selectedMonth; // 1-12
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _loadSelectedRoom();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  Future<void> _loadSelectedRoom() async {
    var roomId = await RoomSelection.getSelectedRoomId();

    // If no room is selected, ensure default room exists and select it
    if (roomId == null || roomId.isEmpty) {
      final rooms = await _db.roomsDao.getAllRooms();

      if (rooms.isEmpty) {
        // Create default room
        await _db.roomsDao.insertRoom(
          RoomsCompanion(
            id: const drift.Value('room-private'),
            name: const drift.Value('Private list'),
            ownerId: const drift.Value('local-user'),
            isShared: const drift.Value(false),
            users: const drift.Value(['local-user']),
          ),
        );
        roomId = 'room-private';
      } else {
        roomId = rooms.first.id;
      }

      await RoomSelection.setSelectedRoomId(roomId);
    }

    if (mounted) {
      setState(() {
        _selectedRoomId = roomId;
        // Clear cache when room changes to prevent showing old data
        _expenses = [];
        _incomes = [];
        _initialLoadDone = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _db.close();
    super.dispose();
  }

  void toggleMode(bool isExpense) {
    setState(() {
      this.isExpense = isExpense;
    });
  }

  void _onMonthFilterChanged(int? month, int? year) {
    setState(() {
      _selectedMonth = month;
      _selectedYear = year;
    });
  }

  List<dynamic> _filterAndSortTransactions(
    List<dynamic> transactions,
    String searchInput,
    String? selectedCategoryId,
  ) {
    List<dynamic> filtered = transactions;

    // Filter by search input if not empty
    if (searchInput.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final description = transaction.description?.toLowerCase() ?? '';
        return description.contains(searchInput.toLowerCase());
      }).toList();
    }

    // Filter by category if selected
    if (selectedCategoryId != null) {
      filtered = filtered.where((transaction) {
        return transaction.category.id == selectedCategoryId;
      }).toList();
    }

    // Filter by month/year if selected
    if (_selectedMonth != null && _selectedYear != null) {
      filtered = filtered.where((transaction) {
        DateTime? date;
        if (transaction is Expense) {
          date = transaction.createdAt;
        } else if (transaction is Income) {
          date = transaction.createdAt;
        }

        if (date != null) {
          return date.year == _selectedYear && date.month == _selectedMonth;
        }
        return false;
      }).toList();
    }

    // Sort from latest to oldest
    filtered.sort((a, b) {
      DateTime? dateA;
      DateTime? dateB;

      if (a is Expense) {
        dateA = a.createdAt;
      } else if (a is Income) {
        dateA = a.createdAt;
      }

      if (b is Expense) {
        dateB = b.createdAt;
      } else if (b is Income) {
        dateB = b.createdAt;
      }

      if (dateA != null && dateB != null) {
        return dateB.compareTo(dateA); // Descending order (latest first)
      }
      return 0;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    // Use the measured header height so the header hugs content. Start with
    // a sensible default and update after layout.
    final double headerHeight = _headerHeight;
    // t goes from 0.0 (no scroll) to 1.0 (scrolled past header)
    final double t = headerHeight > 0
        ? (_scrollOffset / headerHeight).clamp(0.0, 1.0)
        : 0.0;
    // Use an eased curve so the fade feels natural
    final double easedT = Curves.easeOut.transform(t);
    // Header background opacity increases as content scrolls under it
    // Start more opaque for better content visibility
    final double overlayOpacity = lerpDouble(0.95, 0.98, easedT) ?? 0.95;
    // Blur - keep it minimal to avoid blue tint on content
    final double blurSigma = lerpDouble(0.0, 2.0, easedT) ?? 0.0;
    // Content fade: after reaching 100% scroll, content beneath header starts fading
    // Start fading at 95% scroll, completely invisible by 120% scroll
    final double contentFadeT = (t - 0.95).clamp(0.0, 0.25) / 0.25;
    final double contentOpacity =
        lerpDouble(1.0, 0.0, Curves.easeIn.transform(contentFadeT)) ?? 1.0;
    // Theme-aware colors
    final colorScheme = Theme.of(context).colorScheme;
    final miniTextColor = colorScheme.onSurface.withAlpha((0.9 * 255).round());
    // After this frame, measure the header size and update _headerHeight if
    // it changed. We schedule measurement here so it runs after layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final ctx = _headerKey.currentContext;
        if (ctx != null) {
          final h = ctx.size?.height ?? _headerHeight;
          if ((h - _headerHeight).abs() > 1.0) {
            setState(() {
              _headerHeight = h;
            });
          }
        }
      } catch (_) {}
    });

    return Scaffold(
      // Use surface instead of background per new color scheme guidance.
      backgroundColor: colorScheme.surface,
      body: ValueListenableBuilder<String>(
        valueListenable: searchInputNotifier,
        builder: (context, searchInput, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _selectedRoomId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Expense>>(
                    key: ValueKey('expense_$_selectedRoomId'),
                    stream: _db.expensesDao.watchByRoomId(_selectedRoomId!),
                    builder: (context, expenseSnapshot) {
                      // Update cached expenses only if data is available
                      if (expenseSnapshot.hasData) {
                        _expenses = expenseSnapshot.data!;
                      }

                      return StreamBuilder<List<Income>>(
                        key: ValueKey('income_$_selectedRoomId'),
                        stream: _db.incomesDao.watchByRoomId(_selectedRoomId!),
                        builder: (context, incomeSnapshot) {
                          // Update cached incomes only if data is available
                          if (incomeSnapshot.hasData) {
                            _incomes = incomeSnapshot.data!;
                            if (expenseSnapshot.hasData) {
                              _initialLoadDone = true;
                              if (expenseSnapshot.hasData) {
                                _initialLoadDone = true;
                              }
                            }
                          }

                          if (!_initialLoadDone &&
                              (expenseSnapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  incomeSnapshot.connectionState ==
                                      ConnectionState.waiting)) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (expenseSnapshot.hasError ||
                              incomeSnapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${expenseSnapshot.error ?? incomeSnapshot.error}',
                              ),
                            );
                          }

                          // Filter and sort transactions
                          final selectedCategory = ref.watch(
                            selectedCategoryProvider,
                          );
                          final searchEnabled = ref.watch(
                            searchEnabledProvider,
                          );
                          final transactionType = ref.watch(
                            transactionTypeProvider,
                          );

                          final filteredExpenses = _filterAndSortTransactions(
                            _expenses,
                            searchInput,
                            selectedCategory?.id,
                          );
                          final filteredIncomes = _filterAndSortTransactions(
                            _incomes,
                            searchInput,
                            selectedCategory?.id,
                          );

                          // Calculate totals for filtered data
                          final expenseTotal = filteredExpenses.fold<double>(
                            0.0,
                            (sum, expense) => sum + expense.amount,
                          );
                          final incomeTotal = filteredIncomes.fold<double>(
                            0.0,
                            (sum, income) => sum + income.amount,
                          );

                          // Use filtered and sorted data for display
                          // When search is enabled, use transaction type filter
                          final List<dynamic> transactions;
                          if (searchEnabled) {
                            if (transactionType == TransactionType.both) {
                              transactions = [
                                ...filteredExpenses,
                                ...filteredIncomes,
                              ].cast<dynamic>();
                            } else {
                              transactions =
                                  transactionType == TransactionType.expense
                                  ? filteredExpenses.cast<dynamic>()
                                  : filteredIncomes.cast<dynamic>();
                            }
                          } else {
                            // Normal mode: use toggle state
                            transactions =
                                (filteredExpenses.isEmpty &&
                                    filteredIncomes.isEmpty)
                                ? const <dynamic>[]
                                : (isExpense
                                      ? filteredExpenses.cast<dynamic>()
                                      : filteredIncomes.cast<dynamic>());
                          }

                          // Calculate month totals for the month sheet
                          Map<int, double> monthTotals = {};
                          final currentYear = DateTime.now().year;
                          for (int month = 1; month <= 12; month++) {
                            final monthExpenses = _expenses
                                .where(
                                  (e) =>
                                      e.createdAt.month == month &&
                                      e.createdAt.year == currentYear &&
                                      e.roomId == _selectedRoomId,
                                )
                                .toList();
                            final monthIncomes = _incomes
                                .where(
                                  (i) =>
                                      i.createdAt.month == month &&
                                      i.createdAt.year == currentYear &&
                                      i.roomId == _selectedRoomId,
                                )
                                .toList();
                            // Filter by category if selected
                            final selectedCategory = ref.watch(
                              selectedCategoryProvider,
                            );
                            if (selectedCategory != null) {
                              monthExpenses.retainWhere(
                                (e) => e.category.id == selectedCategory.id,
                              );
                              monthIncomes.retainWhere(
                                (i) => i.category.id == selectedCategory.id,
                              );
                            }
                            final expenseSum = monthExpenses.fold(
                              0.0,
                              (sum, e) => sum + e.amount,
                            );
                            final incomeSum = monthIncomes.fold(
                              0.0,
                              (sum, i) => sum + i.amount,
                            );
                            final net = expenseSum - incomeSum;
                            if (net.abs() > 0) monthTotals[month] = net.abs();
                          }

                          // Net total = Expenses - Incomes (overall balance)
                          final totalAmount = expenseTotal - incomeTotal;

                          return Stack(
                            children: [
                              Stack(
                                children: [
                                  // Scrollable content - starts at top of screen so it can scroll under the header
                                  // Wrapped with Opacity for content fade effect
                                  Opacity(
                                    opacity: contentOpacity,
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Add top spacing equal to header height so first item isn't hidden
                                          SizedBox(height: headerHeight),
                                          // Horizontal categories with fade animation
                                          (filteredExpenses.isEmpty &&
                                                  filteredIncomes.isEmpty)
                                              ? CategoriesList(
                                                  key: const ValueKey(
                                                    'categories_empty',
                                                  ),
                                                  transactions: transactions,
                                                  scrollOffset: _scrollOffset,
                                                  hasBothEmptyTransactions:
                                                      true,
                                                )
                                              : AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  switchInCurve: Curves.easeIn,
                                                  switchOutCurve:
                                                      Curves.easeOut,
                                                  transitionBuilder:
                                                      (child, animation) {
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: child,
                                                        );
                                                      },
                                                  child: CategoriesList(
                                                    key: ValueKey(
                                                      searchEnabled
                                                          ? 'categories_search_${transactionType.name}'
                                                          : 'categories_$isExpense',
                                                    ),
                                                    transactions: transactions,
                                                    scrollOffset: _scrollOffset,
                                                    hasBothEmptyTransactions:
                                                        false,
                                                  ),
                                                ),

                                          // Transactions list with mini total and fade animation
                                          AnimatedSwitcher(
                                            duration: Duration(
                                              milliseconds: transactions.isEmpty
                                                  ? 0
                                                  : 200,
                                            ),
                                            switchInCurve: Curves.easeIn,
                                            switchOutCurve: Curves.easeOut,
                                            transitionBuilder:
                                                (child, animation) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  );
                                                },
                                            child: TransactionsList(
                                              key: ValueKey(
                                                transactions.isEmpty
                                                    ? 'transactions_empty'
                                                    : 'transactions_$isExpense',
                                              ),
                                              transactions: transactions,
                                              miniTextColor: miniTextColor,
                                              totalAmount: totalAmount,
                                              onRoomChanged: _loadSelectedRoom,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Sticky header with blur
                                  Header(
                                    key: _headerKey,
                                    blurSigma: blurSigma,
                                    overlayOpacity: overlayOpacity,
                                    isExpense: isExpense,
                                    totalAmount: totalAmount.abs(),
                                    expenseTotal: expenseTotal,
                                    incomeTotal: incomeTotal,
                                    toggleMode: toggleMode,
                                    onRoomChanged: _loadSelectedRoom,
                                    onMonthFilterChanged: _onMonthFilterChanged,
                                    monthTotals: monthTotals,
                                    isSearchActive: ref.watch(
                                      searchEnabledProvider,
                                    ),
                                    // debug overrides
                                    debugBlurOverride: _debugMode == 1
                                        ? 20.0
                                        : null,
                                    debugOverlayColor: _debugMode == 2
                                        ? Colors.purple.withOpacity(0.16)
                                        : null,
                                  ),
                                ],
                              ),
                              // Floating action buttons with search transition
                              FloatingActionButtons(
                                onRoomChanged: _loadSelectedRoom,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
