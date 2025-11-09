import '../../../features/room/domain/entities/expense.dart';
import '../../../features/room/domain/entities/category.dart';

// Mock categories
const mockCategories = {
  'eatOut': Category(
    id: '1',
    icon: '🍔',
    name: 'Eat out',
    description: 'Restaurants and dining',
    color: 0xFFF44336, // Red
  ),
  'transport': Category(
    id: '2',
    icon: '🚗',
    name: 'Transport',
    description: 'Travel and commute',
    color: 0xFF2196F3, // Blue
  ),
  'shopping': Category(
    id: '3',
    icon: '🛍️',
    name: 'Shopping',
    description: 'Retail purchases',
    color: 0xFF9C27B0, // Purple
  ),
  'entertainment': Category(
    id: '4',
    icon: '🎮',
    name: 'Entertainment',
    description: 'Movies, games, fun',
    color: 0xFFFF9800, // Orange
  ),
  'bills': Category(
    id: '5',
    icon: '💡',
    name: 'Bills',
    description: 'Utilities and bills',
    color: 0xFFFFEB3B, // Yellow
  ),
  'health': Category(
    id: '6',
    icon: '💊',
    name: 'Health',
    description: 'Medical and wellness',
    color: 0xFFE91E63, // Pink
  ),
  'groceries': Category(
    id: '7',
    icon: '🛒',
    name: 'Groceries',
    description: 'Food and household items',
    color: 0xFF4CAF50, // Green
  ),
  'salary': Category(
    id: '8',
    icon: '💼',
    name: 'Salary',
    description: 'Monthly salary',
    color: 0xFF009688, // Teal
  ),
};

// Mock expenses data
final mockExpenses = [
  Expense(
    id: '1',
    description: 'Quick lunch with colleagues',
    category: mockCategories['eatOut']!,
    amount: 15.50,
    location: 'Downtown',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Expense(
    id: '2',
    description: 'Trip to office',
    category: mockCategories['transport']!,
    amount: 12.30,
    location: 'Home to Office',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Expense(
    id: '3',
    description: 'Sony WH-1000XM5',
    category: mockCategories['shopping']!,
    amount: 349.99,
    location: 'Best Buy',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Expense(
    id: '4',
    description: 'Monthly subscription',
    category: mockCategories['entertainment']!,
    amount: 15.99,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  ),
  Expense(
    id: '5',
    description: 'October 2025',
    category: mockCategories['bills']!,
    amount: 125.00,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Expense(
    id: '6',
    description: 'Walmart shopping',
    category: mockCategories['groceries']!,
    amount: 87.45,
    location: 'Walmart Supercenter',
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
  ),
  Expense(
    id: '7',
    description: 'Starbucks latte',
    category: mockCategories['eatOut']!,
    amount: 5.75,
    location: 'Starbucks Main St',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Expense(
    id: '8',
    description: 'Full tank',
    category: mockCategories['transport']!,
    amount: 55.00,
    location: 'Shell Gas Station',
    createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
  ),
  Expense(
    id: '9',
    description: 'Vitamins and supplements',
    category: mockCategories['health']!,
    amount: 42.50,
    location: 'CVS Pharmacy',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Expense(
    id: '10',
    description: 'Oppenheimer IMAX',
    category: mockCategories['entertainment']!,
    amount: 28.00,
    location: 'AMC Theater',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Expense(
    id: '11',
    description: 'Date night',
    category: mockCategories['eatOut']!,
    amount: 95.30,
    location: 'La Piazza',
    createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 8)),
  ),
  Expense(
    id: '12',
    description: 'Monthly fiber subscription',
    category: mockCategories['bills']!,
    amount: 79.99,
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
  Expense(
    id: '13',
    description: 'Nike Air Max',
    category: mockCategories['shopping']!,
    amount: 129.99,
    location: 'Nike Store',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Expense(
    id: '14',
    description: 'Weekly metro pass',
    category: mockCategories['transport']!,
    amount: 32.00,
    createdAt: DateTime.now().subtract(const Duration(days: 7, hours: 5)),
  ),
  Expense(
    id: '15',
    description: 'Fresh produce',
    category: mockCategories['groceries']!,
    amount: 45.60,
    location: 'Whole Foods',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
];

// Mock income data
final mockIncomes = [
  Income(
    id: 'i1',
    description: 'November 2025 paycheck',
    category: mockCategories['salary']!,
    amount: 5500.00,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Income(
    id: 'i2',
    description: 'Website project payment',
    category: mockCategories['salary']!,
    amount: 1200.00,
    location: 'Remote',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Income(
    id: 'i3',
    description: 'Credit card rewards',
    category: mockCategories['shopping']!,
    amount: 85.00,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Income(
    id: 'i4',
    description: 'Facebook Marketplace sale',
    category: mockCategories['shopping']!,
    amount: 150.00,
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  Income(
    id: 'i5',
    description: 'Overpayment refund',
    category: mockCategories['bills']!,
    amount: 45.00,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Income(
    id: 'i6',
    description: 'Weekend consulting',
    category: mockCategories['salary']!,
    amount: 800.00,
    createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 3)),
  ),
  Income(
    id: 'i7',
    description: 'Medical expense refund',
    category: mockCategories['health']!,
    amount: 120.00,
    location: 'Insurance Co.',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
  Income(
    id: 'i8',
    description: 'Store credit from returns',
    category: mockCategories['groceries']!,
    amount: 35.00,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Income(
    id: 'i9',
    description: 'Work travel reimbursement',
    category: mockCategories['transport']!,
    amount: 95.00,
    location: 'Company',
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
  Income(
    id: 'i10',
    description: 'Performance bonus',
    category: mockCategories['salary']!,
    amount: 2000.00,
    createdAt: DateTime.now().subtract(const Duration(days: 9)),
  ),
];
