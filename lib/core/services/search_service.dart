import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/author.dart';
import 'author_service.dart';

class SearchService {
  final _authorService = AuthorService();
  late final List<Book> _books;

  SearchService() {
    _initializeBooks();
  }

  void _initializeBooks() {
    final authors = _authorService.getAllAuthors();
    _books = [
      Book(
        id: '1',
        title: 'ፍቅር እስከ መቃብር',
        author: authors.firstWhere((a) => a.id == '1'), // ሐዲስ ዓለማየሁ
        description:
            'A classic Ethiopian romance novel that explores love, sacrifice, and societal expectations.',
        coverUrl: 'assets/images/books/fikir_eske_mekabir.jpeg',
        filePath: 'assets/books/fikir_eske_mekabir.pdf',
        rating: 4.8,
        categories: ['1', '3'], // ልቦለድ and ፍቅር
        publishedAt: DateTime(1968, 1, 1),
      ),
      Book(
        id: '2',
        title: 'የተቆለፈው መዝገብ',
        author: authors.firstWhere((a) => a.id == '1'), // ዳግም ወርቅነህ
        description:
            'A gripping tale of mystery and supernatural events in modern Ethiopia.',
        coverUrl: 'assets/images/books/yetekolefew_mezgeb.jpeg',
        filePath: 'assets/books/yetekolefew_mezgeb.pdf',
        rating: 4.5,
        categories: ['2'], // ታሪክ
        publishedAt: DateTime(2010, 6, 15),
      ),
      Book(
        id: '3',
        title: 'The Alchemist',
        author: authors.firstWhere((a) => a.id == '1'), // Paulo Coelho
        description:
            'A mystical story about following your dreams and finding your destiny.',
        coverUrl: 'assets/images/books/alchemist.jpeg',
        filePath: 'assets/books/alchemist.pdf',
        rating: 4.7,
        categories: ['7', '4'], // ሳይንስ and ትምህርት
        publishedAt: DateTime(1988, 1, 1),
      ),
      Book(
        id: '4',
        title: 'የልጆች ታሪኮች',
        author: authors.firstWhere((a) => a.id == '1'), // ሰላም ተፈራ
        description: 'አስደሳች የልጆች ታሪኮች',
        coverUrl: 'assets/images/books/1.jpeg',
        filePath: 'assets/books/book6.pdf',
        rating: 4.6,
        categories: ['6'], // ልጆች
        publishedAt: DateTime(2022, 7, 1),
      ),
      Book(
        id: '5',
        title: 'የሳይንስ መሰረታዊ እውቀት',
        author: authors.firstWhere((a) => a.id == '5'), // ፀሐይ መኮንን
        description: 'መሰረታዊ የሳይንስ ትምህርት',
        coverUrl: 'assets/images/books/2.jpeg',
        filePath: 'assets/books/book7.pdf',
        rating: 4.4,
        categories: ['7', '4'], // ሳይንስ and ትምህርት
        publishedAt: DateTime(2021, 9, 15),
      ),
      Book(
        id: '6',
        title: 'የፍቅር ማዕበል',
        author: authors.firstWhere((a) => a.id == '6'), // መስፍን ኃይሌ
        description: 'ሰቆቃዊ የፍቅር ታሪክ',
        coverUrl: 'assets/images/books/3.jpeg',
        filePath: 'assets/books/book8.pdf',
        rating: 4.7,
        categories: ['3'], // ፍቅር
        publishedAt: DateTime(2020, 2, 14),
      ),
      Book(
        id: '7',
        title: 'የአፄ ቴዎድሮስ ታሪክ',
        author: authors.firstWhere((a) => a.id == '7'), // ገብረ ሕይወት
        description: 'የአፄ ቴዎድሮስ ሕይወት ታሪክ',
        coverUrl: 'assets/images/books/4.jpeg',
        filePath: 'assets/books/book9.pdf',
        rating: 4.9,
        categories: ['2'], // ታሪክ
        publishedAt: DateTime(2018, 4, 11),
      ),
      Book(
        id: '8',
        title: 'የልጆች መዝሙር',
        author: authors.firstWhere((a) => a.id == '8'), // ብርሃነ ስላሴ
        description: 'የልጆች መዝሙሮች ስብስብ',
        coverUrl: 'assets/images/books/5.jpeg',
        filePath: 'assets/books/book10.pdf',
        rating: 4.5,
        categories: ['6', '5'], // ልጆች and ሃይማኖት
        publishedAt: DateTime(2023, 1, 1),
      ),
      Book(
        id: '9',
        title: 'የሕይወት ጥበብ',
        author: authors.firstWhere((a) => a.id == '9'), // አበበ ቢቂላ
        description: 'ስለ ሕይወት የሚያስተምር መጽሐፍ',
        coverUrl: 'assets/images/books/6.jpeg',
        filePath: 'assets/books/book11.pdf',
        rating: 4.6,
        categories: ['1'], // ልቦለድ
        publishedAt: DateTime(2021, 5, 5),
      ),
      Book(
        id: '10',
        title: 'የፊዚክስ መሰረታዊ ሃሳቦች',
        author: authors.firstWhere((a) => a.id == '10'), // ዮሴፍ ተሾመ
        description: 'መሰረታዊ የፊዚክስ ጽንሰ-ሃሳቦች',
        coverUrl: 'assets/images/books/book12.jpg',
        filePath: 'assets/books/book12.pdf',
        rating: 4.3,
        categories: ['7', '4'], // ሳይንስ and ትምህርት
        publishedAt: DateTime(2022, 8, 30),
      ),
      Book(
        id: '11',
        title: 'የእስልምና መሰረታዊ እምነቶች',
        author: authors.firstWhere((a) => a.id == '11'), // ሙሐመድ አህመድ
        description: 'የእስልምና እምነት መሰረታዊ ትምህርቶች',
        coverUrl: 'assets/images/books/book13.jpg',
        filePath: 'assets/books/book13.pdf',
        rating: 4.8,
        categories: ['5'], // ሃይማኖት
        publishedAt: DateTime(2020, 5, 23),
      ),
      Book(
        id: '12',
        title: 'የአማርኛ ሰዋስው',
        author: authors.firstWhere((a) => a.id == '12'), // ታደሰ መኮንን
        description: 'የአማርኛ ቋንቋ ሰዋስው',
        coverUrl: 'assets/images/books/book14.jpg',
        filePath: 'assets/books/book14.pdf',
        rating: 4.4,
        categories: ['4'], // ትምህርት
        publishedAt: DateTime(2021, 11, 11),
      ),
      Book(
        id: '13',
        title: 'የፍቅር ጨረቃ',
        author: authors.firstWhere((a) => a.id == '13'), // ሰሎሞን ደረሰ
        description: 'ልብ የሚነካ የፍቅር ታሪክ',
        coverUrl: 'assets/images/books/book15.jpg',
        filePath: 'assets/books/book15.pdf',
        rating: 4.7,
        categories: ['3'], // ፍቅር
        publishedAt: DateTime(2023, 2, 14),
      ),
    ];
  }

  List<Book> searchBooks(String query) {
    if (query.isEmpty) {
      return _books;
    }

    final lowercaseQuery = query.toLowerCase();
    return _books.where((book) {
      final lowercaseTitle = book.title.toLowerCase();
      final lowercaseAuthor = book.author.name.toLowerCase();
      final lowercaseDescription = book.description.toLowerCase();
      final matchesCategories = book.categories.any(
        (category) => category.toLowerCase().contains(lowercaseQuery),
      );

      return lowercaseTitle.contains(lowercaseQuery) ||
          lowercaseAuthor.contains(lowercaseQuery) ||
          lowercaseDescription.contains(lowercaseQuery) ||
          matchesCategories;
    }).toList();
  }

  void handleSearch(String query) {
    debugPrint('Searching for: $query');
    final results = searchBooks(query);
    debugPrint('Found ${results.length} results');

    // Here you would typically:
    // 1. Update state in a state management solution
    // 2. Show results in a search results screen
    // 3. Cache results for faster subsequent searches
    // 4. Handle errors and edge cases

    // For now, we'll just print the results
    for (final book in results) {
      debugPrint(
          '${book.title} by ${book.author.name} (${book.formattedPublishDate})');
      debugPrint('Categories: ${book.categories.join(", ")}');
    }
  }

  List<Book> getAllBooks() => _books;

  List<Book> getBooksByCategory(String category) {
    return _books.where((book) => book.hasCategory(category)).toList();
  }

  List<Book> getPopularBooks() {
    return _books.where((book) => book.rating >= 4.5).toList();
  }

  List<Book> getBooksByYear(int year) {
    return _books.where((book) => book.publishYear == year).toList();
  }

  List<Book> getBooksByAuthor(String authorId, {String? excludeBookId}) {
    return _books
        .where((book) =>
            book.author.id == authorId &&
            (excludeBookId == null || book.id != excludeBookId))
        .toList();
  }

  List<Book> getRecentBooks() {
    final currentYear = DateTime.now().year;
    return _books.where((book) => currentYear - book.publishYear <= 5).toList();
  }
}
