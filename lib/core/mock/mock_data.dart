import '../../features/auth/domain/entities/auth_token.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/catalog/domain/entities/work.dart';
import '../../features/profile/domain/entities/dashboard_stats.dart';
import '../../features/reader/domain/entities/chapter.dart';

/// Datos de prueba centralizados para toda la aplicación.
///
/// Este archivo es el único que cambia cuando se conecta la API real.
/// Cada MockRepository consume datos de aquí.
class MockData {
  MockData._();

  // ── Usuario logueado ────────────────────────────────────────────
  static final currentUser = User(
    id: 'usr_001',
    email: 'ak.varela@kotoba.app',
    username: 'A.K. Varela',
    bio: 'Escribo mundos donde la física es opcional...',
    avatarUrl: 'https://picsum.photos/seed/kotoba-user/200',
    bannerUrl: 'https://picsum.photos/seed/kotoba-banner/800/300',
    age: 28,
    country: 'México',
    socialLinks: const {
      'x': 'https://x.com/akvarela',
      'instagram': 'https://instagram.com/akvarela',
      'website': 'https://akvarela.com',
    },
    role: 'author',
    followers: 1204,
    following: 87,
    worksCount: 3,
    totalReads: 48300,
    createdAt: DateTime(2024, 3, 15),
  );

  // ── Auth Token ──────────────────────────────────────────────────
  static final authToken = AuthToken(
    accessToken: 'mock_access_token_xyz',
    refreshToken: 'mock_refresh_token_xyz',
    expiresAt: DateTime.now().add(const Duration(days: 7)),
  );

  // ── Obras — Tendencias ──────────────────────────────────────────
  static final List<Work> myAuthoredWorks = [
    Work(
      id: 'my_work_1',
      title: 'Ecos de Obsidiana',
      authorId: 'diego_ortiz',
      authorName: 'Diego Ortiz',
      genre: 'Fantasía',
      coverUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80',
      synopsis: 'En una tierra olvidada donde los recuerdos toman forma física, un joven cartógrafo debe trazar el mapa de los sueños perdidos.',
      tags: const ['Fantasía', 'Misterio', 'Magia'],
      viewCount: 1542,
      rating: 4.9,
      chapterCount: 12,
      status: 'ongoing',
      publishedAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Work(
      id: 'my_work_2',
      title: 'Voces de la Ciudad de Cristal',
      authorId: 'diego_ortiz',
      authorName: 'Diego Ortiz',
      genre: 'Ciencia Ficción',
      coverUrl: 'https://images.unsplash.com/photo-1605806616949-1e87b487cb2a?w=400&q=80',
      synopsis: 'Una metrópolis suspendida en el cielo esconde secretos ancestrales bajo su superficie translúcida.',
      tags: const ['Sci-Fi', 'Aventura', 'Utopía'],
      viewCount: 3890,
      rating: 4.7,
      chapterCount: 8,
      status: 'ongoing',
      publishedAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static final List<Work> myDraftWorks = [
    Work(
      id: 'my_draft_1',
      title: 'BUNNY GIRL [ONESHOT]',
      authorId: 'diego_ortiz',
      authorName: 'Diego Ortiz',
      genre: 'Romance',
      coverUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400&q=80',
      synopsis: 'Un oneshot romántico.',
      tags: const ['Romance', 'Corto'],
      viewCount: 0,
      rating: 0,
      chapterCount: 1, // drafted part
      status: 'draft',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final trendingWorks = <Work>[
    Work(
      id: 'wrk_001',
      title: 'El Silencio de Neón',
      authorId: 'usr_001',
      authorName: 'A.K. Varela',
      coverUrl: 'https://picsum.photos/seed/neon-silence/400/600',
      synopsis:
          'In the sprawling metropolis of Neo-Kyoto, memory is a commodity traded in back alleys. Detective Kaito is a \'Recollector,\' tasked with extracting suppressed traumas from high-profile clients. When a routine extraction reveals a conspiracy involving the city\'s synthetic elite, Kaito finds himself hunted by the very megacorporation that employs him.',
      genre: 'Ciberpunk',
      tags: ['Ciberpunk', 'Thriller'],
      status: 'ongoing',
      chapterCount: 24,
      wordCount: 85420,
      viewCount: 18000,
      rating: 4.9,
      ratingCount: 156,
      frequency: 'weekly',
      publishedAt: DateTime(2024, 6, 1),
      updatedAt: DateTime(2024, 12, 15),
    ),
    Work(
      id: 'wrk_002',
      title: 'Ecos del Vacío',
      authorId: 'usr_002',
      authorName: 'M. Santoro',
      coverUrl: 'https://picsum.photos/seed/ecos-vacio/400/600',
      synopsis:
          'En una estación espacial abandonada, un archivero descubre un registro sonoro que no debería existir: la voz de una civilización que desapareció hace mil años.',
      genre: 'Ciencia Ficción',
      tags: ['Ciencia Ficción', 'Misterio'],
      status: 'completed',
      chapterCount: 18,
      wordCount: 62000,
      viewCount: 24000,
      rating: 4.8,
      ratingCount: 203,
      publishedAt: DateTime(2024, 2, 10),
      updatedAt: DateTime(2024, 11, 20),
    ),
    Work(
      id: 'wrk_003',
      title: 'Midnight at the Onsen',
      authorId: 'usr_003',
      authorName: 'L. Fujimoto',
      coverUrl: 'https://picsum.photos/seed/midnight-onsen/400/600',
      synopsis:
          'Historias entrelazadas de los huéspedes de unas aguas termales que solo aparecen una noche cada década.',
      genre: 'Fantasía Oscura',
      tags: ['Fantasía Oscura', 'Misterio'],
      status: 'completed',
      chapterCount: 12,
      wordCount: 41000,
      viewCount: 6300,
      rating: 4.7,
      ratingCount: 89,
      publishedAt: DateTime(2024, 4, 5),
      updatedAt: DateTime(2024, 10, 30),
    ),
    Work(
      id: 'wrk_004',
      title: 'La Memoria del Polvo',
      authorId: 'usr_004',
      authorName: 'R. Castañeda',
      coverUrl: 'https://picsum.photos/seed/memoria-polvo/400/600',
      synopsis:
          'En una ciudad donde los recuerdos pueden embotellarse y vender, un archivista descubre un frasco sin etiqueta que contiene la memoria más peligrosa del siglo.',
      genre: 'Fantasía',
      tags: ['Fantasía', 'Drama'],
      status: 'ongoing',
      chapterCount: 31,
      wordCount: 112000,
      viewCount: 35000,
      rating: 4.6,
      ratingCount: 312,
      frequency: 'biweekly',
      publishedAt: DateTime(2023, 11, 1),
      updatedAt: DateTime(2024, 12, 10),
    ),
    Work(
      id: 'wrk_005',
      title: 'Anatomía de un Instante',
      authorId: 'usr_005',
      authorName: 'L. Montenegro',
      coverUrl: 'https://picsum.photos/seed/anatomia-instante/400/600',
      synopsis:
          'Un ensayo poético sobre la brevedad de las decisiones irreversibles. Cada capítulo es un momento congelado en el tiempo.',
      genre: 'Romance',
      tags: ['Romance', 'Drama'],
      status: 'completed',
      chapterCount: 8,
      wordCount: 22000,
      viewCount: 9800,
      rating: 4.5,
      ratingCount: 67,
      publishedAt: DateTime(2024, 7, 20),
      updatedAt: DateTime(2024, 9, 15),
    ),
    Work(
      id: 'wrk_006',
      title: 'Versos de Ceniza',
      authorId: 'usr_006',
      authorName: 'Varios Autores',
      coverUrl: 'https://picsum.photos/seed/versos-ceniza/400/600',
      synopsis:
          'Recopilación de poemas ganadores del certamen de otoño. Voces nuevas que arden con intensidad.',
      genre: 'Horror',
      tags: ['Horror', 'Poesía'],
      status: 'completed',
      chapterCount: 15,
      wordCount: 18000,
      viewCount: 4200,
      rating: 4.3,
      ratingCount: 45,
      publishedAt: DateTime(2024, 10, 1),
      updatedAt: DateTime(2024, 10, 31),
    ),
  ];

  // ── Obras — Búsqueda / Más resultados ───────────────────────────
  static final searchResults = <Work>[
    ...trendingWorks,
    Work(
      id: 'wrk_007',
      title: 'Neon Rain & Paper Cranes',
      authorId: 'usr_007',
      authorName: 'Elias Thorne',
      coverUrl: 'https://picsum.photos/seed/neon-rain/400/600',
      synopsis:
          'The rain in Neo-Kyoto didn\'t wash away sins; it merely diluted them into the gutters.',
      genre: 'Ciberpunk',
      tags: ['Ciberpunk', 'Noir'],
      status: 'ongoing',
      chapterCount: 24,
      wordCount: 85420,
      viewCount: 14000,
      rating: 4.8,
      ratingCount: 124,
      frequency: 'weekly',
      publishedAt: DateTime(2024, 5, 1),
      updatedAt: DateTime(2024, 12, 1),
    ),
    Work(
      id: 'wrk_008',
      title: 'Crónicas del Abismo',
      authorId: 'usr_008',
      authorName: 'D. Ortega',
      coverUrl: 'https://picsum.photos/seed/cronicas-abismo/400/600',
      synopsis: 'En las profundidades del océano, una civilización perdida despierta.',
      genre: 'Ciencia Ficción',
      tags: ['Ciencia Ficción', 'Aventura'],
      status: 'ongoing',
      chapterCount: 16,
      wordCount: 54000,
      viewCount: 7800,
      rating: 4.4,
      ratingCount: 78,
      publishedAt: DateTime(2024, 8, 15),
      updatedAt: DateTime(2024, 12, 5),
    ),
    Work(
      id: 'wrk_009',
      title: 'El Relojero Ciego',
      authorId: 'usr_009',
      authorName: 'P. Ríos',
      coverUrl: 'https://picsum.photos/seed/relojero/400/600',
      synopsis: 'Un relojero que puede ver el futuro de cualquiera excepto el suyo.',
      genre: 'Fantasía',
      tags: ['Fantasía', 'Thriller'],
      status: 'completed',
      chapterCount: 22,
      wordCount: 78000,
      viewCount: 15200,
      rating: 4.7,
      ratingCount: 198,
      publishedAt: DateTime(2024, 1, 10),
      updatedAt: DateTime(2024, 8, 25),
    ),
  ];

  // ── Capítulos de muestra ────────────────────────────────────────
  static final sampleChapters = <Chapter>[
    Chapter(
      id: 'ch_001',
      workId: 'wrk_007',
      number: 1,
      title: 'The Awakening',
      wordCount: 3200,
      readTimeMinutes: 15,
      publishedAt: DateTime(2024, 5, 1),
      content: '''The rain had not stopped for three days. It drummed against the windowpanes like a thousand tiny fingers, a relentless percussion that seeped into the marrow of the old house. Kaelen sat in the dimly lit study, the only illumination coming from a solitary desk lamp that cast long, distorted shadows against the oak-paneled walls. The book lay open before him, its pages yellowed and brittle with age, the ink faded to a ghostly rust.

He traced the unfamiliar symbols with a trembling finger, his breath catching in his throat as the lines seemed to writhe and twist beneath his gaze. It was a sensation he had grown accustomed to over the past few weeks, a subtle vibration that resonated deep within his chest whenever he opened the tome. The whispers had started soon after. Faint at first, little more than a rustle of leaves in the wind, they had grown steadily louder, more insistent, filling the silent spaces of his mind with forgotten languages and forbidden truths.

"To seek the silence is not to find emptiness, but to hear the roar of everything that has been forgotten."

He closed his eyes, leaning back in the heavy leather chair. The cold dampness of the room pressed against him, but a feverish heat burned beneath his skin. The artifact they had recovered from the ruins of Aethergard was proving to be far more dangerous than the Council had anticipated. They believed it to be a mere chronicle, a historical ledger of a dead civilization. They were fools.

A sudden, sharp rap at the heavy mahogany door shattered the fragile quiet. Kaelen snapped his eyes open, his heart hammering a frantic rhythm against his ribs. He instinctively slammed the book shut, a puff of ancient dust rising in the lamplight.

"Enter," he called out, his voice hoarse, sounding foreign even to his own ears.

The door groaned open, revealing the silhouetted figure of Elara, her usually pristine uniform damp and clinging to her form. Her eyes, normally bright with a cynical intelligence, were wide and dark with an unspoken fear. She stepped into the room, leaving muddy footprints on the Persian rug.

"It's begun," she said, her voice a fragile whisper that nonetheless seemed to echo in the cavernous study. "The perimeter wards have fallen."

Kaelen stood slowly, the weight of the moment settling heavily upon his shoulders. He glanced once more at the closed book, its leather cover seeming to pulse with a dark, rhythmic life. He reached out, his hand hovering over it for a fraction of a second, before grasping it firmly. It was warm to the touch.

"Then we have no more time," he replied, moving towards the door. The drumming of the rain outside seemed to intensify, transforming from a scattered percussion into a unified, thunderous roar. The silence was over.''',
    ),
    Chapter(
      id: 'ch_002',
      workId: 'wrk_007',
      number: 2,
      title: 'Synthetic Tears',
      wordCount: 4100,
      readTimeMinutes: 22,
      publishedAt: DateTime(2024, 5, 8),
      content: '''The neon signs of Neo-Kyoto bled watercolor reflections across the rain-slicked streets. Kaelen pulled his collar higher against the downpour, the book secured in a waterproof case strapped to his back. The weight of it was a constant reminder — a tether to something ancient in a world obsessed with the new.

District 7 at midnight was a symphony of contradictions: the hum of quantum processors from the tech towers above, the sizzle of street vendors cooking synthetic protein below. Kaelen navigated the narrow alleys with practiced ease, his augmented left eye scanning for surveillance drones.

"You're being followed," Elara's voice crackled through his earpiece. "Two assets. Corporate extraction team, judging by their thermal signatures."

He didn't look back. Looking back was for people who had the luxury of second thoughts.

The rain intensified, turning the alley into a shallow river. His boots splashed through puddles that reflected fractured neon — pink, blue, gold — a kaleidoscope of artificial light in a city that had forgotten what stars looked like.

He ducked into the Floating Lantern, a tea house that existed in the space between legal and forgotten. The owner, a woman known only as Grandmother Hoshi, looked up from her ancient analog register and nodded once. She had been expecting him.

"The usual room," she said, her voice carrying the weight of decades of secrets kept. "Your friend is already waiting."

The room was small, lined with paper screens that depicted mountains no one alive had ever seen. A figure sat cross-legged at the low table, steam rising from two cups of matcha.

"You brought it," the figure said. Not a question.

Kaelen placed the case on the table. "It's changing. The symbols... they're rewriting themselves."

A long pause filled the room, broken only by the muffled percussion of rain on the roof tiles. The figure reached forward, and in the warm glow of the paper lantern, Kaelen saw their face clearly for the first time: half flesh, half polished chrome, with one eye that shone with the unmistakable amber of pre-Collapse technology.

"Then we're already too late," they whispered. "Or precisely on time. With artifacts like these, it's often the same thing."''',
    ),
    Chapter(
      id: 'ch_003',
      workId: 'wrk_007',
      number: 3,
      title: 'Origami Protocol',
      wordCount: 3800,
      readTimeMinutes: 18,
      publishedAt: DateTime(2024, 5, 15),
      isLocked: true,
      content: 'Este capítulo requiere suscripción premium.',
    ),
  ];

  // ── Nuevos autores ──────────────────────────────────────────────
  static final newAuthors = <User>[
    User(
      id: 'usr_010',
      email: 'elena@kotoba.app',
      username: 'Elena R.',
      avatarUrl: 'https://picsum.photos/seed/elena/200',
      role: 'author',
      createdAt: DateTime(2024, 11, 1),
    ),
    User(
      id: 'usr_011',
      email: 'david@kotoba.app',
      username: 'David S.',
      avatarUrl: 'https://picsum.photos/seed/david/200',
      role: 'author',
      createdAt: DateTime(2024, 11, 15),
    ),
    User(
      id: 'usr_012',
      email: 'sofia@kotoba.app',
      username: 'Sofía M.',
      avatarUrl: 'https://picsum.photos/seed/sofia/200',
      role: 'author',
      createdAt: DateTime(2024, 12, 1),
    ),
  ];

  // ── Dashboard Stats ─────────────────────────────────────────────
  static final dashboardStats = DashboardStats(
    activeReaders: 2847,
    totalReads: 48320,
    publishedWorks: 3,
    followers: 1204,
    nextPublicationDeadline:
        DateTime.now().add(const Duration(hours: 62, minutes: 45)),
    engagementData: List.generate(30, (i) {
      final base = 40.0 + (i * 1.5);
      final variance = (i % 7 == 0) ? -15.0 : (i % 5 == 0 ? 20.0 : 0);
      return EngagementPoint(
        date: DateTime.now().subtract(Duration(days: 30 - i)),
        value: base + variance,
      );
    }),
  );

  // ── Géneros disponibles ─────────────────────────────────────────
  static const genres = [
    'Todos',
    'Ciencia Ficción',
    'Fantasía',
    'Ciberpunk',
    'Fantasía Oscura',
    'Thriller',
    'Misterio',
    'Romance',
    'Horror',
    'Drama',
    'Poesía',
  ];

  // ── Reseñas ─────────────────────────────────────────────────────
  static const sampleReviews = [
    {
      'text': 'Una obra maestra del género. La prosa es densa y atmosférica...',
      'author': '@cyberreader99',
    },
    {
      'text':
          'Los personajes se sienten reales y el mundo está increíblemente detallado.',
      'author': '@litnoir_fan',
    },
  ];

}
