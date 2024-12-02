import '../models/author.dart';

class AuthorService {
  static final List<Author> _authors = [
    Author(
      id: '1',
      name: 'Bealu Girma',
      bio:
          'Ethiopian journalist and novelist known for his investigative works',
      imageUrl: 'assets/authors/bealu_girma.jpg',
      birthDate: DateTime(1940),
      genres: ['Fiction', 'Journalism', 'Political'],
    ),
    Author(
      id: '2',
      name: 'Sebhat Gebre-Egziabher',
      bio: 'Renowned Ethiopian writer known for his unique literary style',
      imageUrl: 'assets/authors/sebhat_gebre_egziabher.jpg',
      birthDate: DateTime(1936),
      genres: ['Fiction', 'Literary'],
    ),
    Author(
      id: '3',
      name: 'Haddis Alemayehu',
      bio: 'One of Ethiopia\'s most respected authors and diplomats',
      imageUrl: 'assets/authors/haddis_alemayehu.jpg',
      birthDate: DateTime(1910),
      genres: ['Fiction', 'Political', 'Historical'],
    ),
    Author(
      id: '4',
      name: 'Tsegaye Gebre-Medhin',
      bio: 'Ethiopia\'s Poet Laureate and prominent playwright',
      imageUrl: 'assets/authors/tsegaye_gebre_medhin.jpg',
      birthDate: DateTime(1936),
      genres: ['Poetry', 'Drama', 'Theatre'],
    ),
    Author(
      id: '5',
      name: 'Mammo Wudneh',
      bio: 'Notable Ethiopian author and educator',
      imageUrl: 'assets/authors/mammo_wudneh.jpg',
      birthDate: DateTime(1931),
      genres: ['Fiction', 'Educational'],
    ),
    Author(
      id: '6',
      name: 'Dagnachew Worku',
      bio: 'Influential Ethiopian writer and playwright',
      imageUrl: 'assets/authors/dagnachew_worku.jpg',
      birthDate: DateTime(1936),
      genres: ['Fiction', 'Drama'],
    ),
    Author(
      id: '7',
      name: 'Mengistu Lemma',
      bio: 'Pioneer of modern Ethiopian theater and literature',
      imageUrl: 'assets/authors/mengistu_lemma.jpg',
      birthDate: DateTime(1925),
      genres: ['Drama', 'Poetry', 'Satire'],
    ),
    Author(
      id: '8',
      name: 'Mengistu Lemma',
      bio: 'Pioneer of modern Ethiopian theater and literature',
      imageUrl: 'assets/authors/mengistu_lemma.jpg',
      birthDate: DateTime(1925),
      genres: ['Drama', 'Poetry', 'Satire'],
    ),
    Author(
      id: '9',
      name: 'Mengistu Lemma',
      bio: 'Pioneer of modern Ethiopian theater and literature',
      imageUrl: 'assets/authors/mengistu_lemma.jpg',
      birthDate: DateTime(1925),
      genres: ['Drama', 'Poetry', 'Satire'],
    ),
    Author(
      id: '10',
      name: 'Mengistu Lemma',
      bio: 'Pioneer of modern Ethiopian theater and literature',
      imageUrl: 'assets/authors/mengistu_lemma.jpg',
      birthDate: DateTime(1925),
      genres: ['Drama', 'Poetry', 'Satire'],
    ),
    Author(
      id: '11',
      name: 'Mengistu Lemma',
      bio: 'Pioneer of modern Ethiopian theater and literature',
      imageUrl: 'assets/authors/mengistu_lemma.jpg',
      birthDate: DateTime(1925),
      genres: ['Drama', 'Poetry', 'Satire'],
    ),
    Author(
      id: '12',
      name: 'Mengistu Lemma',
      bio: 'Pioneer of modern Ethiopian theater and literature',
      imageUrl: 'assets/authors/mengistu_lemma.jpg',
      birthDate: DateTime(1925),
      genres: ['Drama', 'Poetry', 'Satire'],
    ),
    Author(
      id: '13',
      name: 'Mengistu Lemma',
      bio: 'Pioneer of modern Ethiopian theater and literature',
      imageUrl: 'assets/authors/mengistu_lemma.jpg',
      birthDate: DateTime(1925),
      genres: ['Drama', 'Poetry', 'Satire'],
    ),
    Author(
      id: '14',
      name: 'Mengistu Lemma',
      bio: 'Pioneer of modern Ethiopian theater and literature',
      imageUrl: 'assets/authors/mengistu_lemma.jpg',
      birthDate: DateTime(1925),
      genres: ['Drama', 'Poetry', 'Satire'],
    ),
    Author(
      id: '15',
      name: 'Mengistu Lemma',
      bio: 'Pioneer of modern Ethiopian theater and literature',
      imageUrl: 'assets/authors/mengistu_lemma.jpg',
      birthDate: DateTime(1925),
      genres: ['Drama', 'Poetry', 'Satire'],
    ),
  ];

  // Get all authors
  List<Author> getAllAuthors() {
    return List.from(_authors);
  }

  // Get author by ID
  Author? getAuthorById(String id) {
    try {
      return _authors.firstWhere((author) => author.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get authors by genre
  List<Author> getAuthorsByGenre(String genre) {
    return _authors.where((author) => author.genres.contains(genre)).toList();
  }

  // Search authors by name
  List<Author> searchAuthors(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _authors
        .where((author) =>
            author.name.toLowerCase().contains(lowercaseQuery) ||
            (author.bio?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList();
  }
}
