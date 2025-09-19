import '../models/user.dart';
import '../models/category.dart';
import '../models/article.dart';
import '../models/ticket.dart';

class DummyData {
  // Categories
  static final List<Category> categories = [
    Category(
      id: '1',
      name: 'Pendidikan',
      description: 'Artikel seputar pendidikan dan pembelajaran',
      icon: 'book',
      color: '#4A90E2',
    ),
    Category(
      id: '2',
      name: 'Kesehatan',
      description: 'Informasi kesehatan dan gaya hidup sehat',
      icon: 'heart',
      color: '#4FD1C7',
    ),
    Category(
      id: '3',
      name: 'Ekonomi',
      description: 'Berita dan tips ekonomi syariah',
      icon: 'chart',
      color: '#9AE6B4',
    ),
    Category(
      id: '4',
      name: 'Keagamaan',
      description: 'Kajian Islam dan kegiatan keagamaan',
      icon: 'mosque',
      color: '#2D3748',
    ),
  ];

  // Users
  static final List<User> users = [
    User(
      id: '1',
      name: 'Ahmad Fauzi',
      email: 'ahmad.fauzi@muhammadiyah.org',
      phone: '+62812345678',
      photo: '/placeholder.svg?height=100&width=100',
      role: 'member',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    User(
      id: '2',
      name: 'Siti Aminah',
      email: 'siti.aminah@muhammadiyah.org',
      phone: '+62812345679',
      photo: '/placeholder.svg?height=100&width=100',
      role: 'admin',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    User(
      id: '3',
      name: 'Muhammad Rizki',
      email: 'muhammad.rizki@muhammadiyah.org',
      phone: '+62812345680',
      photo: '/placeholder.svg?height=100&width=100',
      role: 'member',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  // Articles
  static final List<Article> articles = [
    Article(
      id: '1',
      title: 'Pentingnya Pendidikan Karakter dalam Islam',
      content: '''
Pendidikan karakter merupakan salah satu aspek fundamental dalam sistem pendidikan Islam. Dalam perspektif Muhammadiyah, pendidikan tidak hanya bertujuan untuk mencerdaskan akal, tetapi juga membentuk akhlak mulia.

Rasulullah SAW bersabda: "Sesungguhnya aku diutus untuk menyempurnakan akhlak yang mulia." Hadits ini menjadi landasan utama dalam pengembangan pendidikan karakter di lingkungan Muhammadiyah.

Beberapa nilai karakter yang perlu ditanamkan antara lain:
1. Kejujuran (Shiddiq)
2. Tanggung jawab (Amanah)
3. Kecerdasan (Fathonah)
4. Komunikatif (Tabligh)

Implementasi pendidikan karakter dapat dilakukan melalui berbagai cara, seperti keteladanan guru, pembiasaan positif, dan integrasi nilai-nilai Islam dalam setiap mata pelajaran.
      ''',
      excerpt: 'Pendidikan karakter merupakan aspek fundamental dalam sistem pendidikan Islam yang bertujuan membentuk akhlak mulia.',
      photo: '/placeholder.svg?height=200&width=300',
      categoryId: '1',
      authorId: '2',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      views: 245,
      isPublished: true,
    ),
    Article(
      id: '2',
      title: 'Hidup Sehat Menurut Ajaran Islam',
      content: '''
Islam mengajarkan umatnya untuk menjaga kesehatan sebagai amanah dari Allah SWT. Konsep hidup sehat dalam Islam tidak hanya mencakup aspek fisik, tetapi juga mental dan spiritual.

Beberapa prinsip hidup sehat dalam Islam:

1. Makan dan Minum Secukupnya
"Makanlah dan minumlah, tetapi jangan berlebihan. Sesungguhnya Allah tidak menyukai orang-orang yang berlebihan." (QS. Al-A'raf: 31)

2. Olahraga dan Aktivitas Fisik
Rasulullah SAW menganjurkan umatnya untuk beraktivitas fisik seperti berkuda, berenang, dan memanah.

3. Istirahat yang Cukup
Islam mengatur waktu istirahat yang seimbang antara ibadah, kerja, dan istirahat.

4. Kebersihan (Thaharah)
"Kebersihan adalah sebagian dari iman" - hadits yang menunjukkan pentingnya menjaga kebersihan.

5. Menghindari Hal-hal yang Haram
Seperti alkohol, narkoba, dan makanan haram lainnya yang dapat merusak kesehatan.
      ''',
      excerpt: 'Islam mengajarkan konsep hidup sehat yang menyeluruh, mencakup aspek fisik, mental, dan spiritual.',
      photo: '/placeholder.svg?height=200&width=300',
      categoryId: '2',
      authorId: '1',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      views: 189,
      isPublished: true,
    ),
    Article(
      id: '3',
      title: 'Ekonomi Syariah: Solusi Keuangan Berkelanjutan',
      content: '''
Ekonomi syariah menawarkan sistem keuangan yang adil dan berkelanjutan berdasarkan prinsip-prinsip Islam. Sistem ini menghindari riba, gharar (ketidakpastian), dan maysir (perjudian).

Prinsip-prinsip Ekonomi Syariah:

1. Larangan Riba
Riba dalam segala bentuknya dilarang dalam Islam karena dapat menimbulkan ketidakadilan ekonomi.

2. Bagi Hasil (Mudharabah)
Sistem bagi hasil yang adil antara pemilik modal dan pengelola usaha.

3. Jual Beli yang Halal
Transaksi harus jelas, transparan, dan tidak merugikan salah satu pihak.

4. Zakat sebagai Instrumen Redistribusi
Zakat berfungsi sebagai alat pemerataan kekayaan dalam masyarakat.

5. Investasi Produktif
Dana harus diinvestasikan pada sektor riil yang produktif dan bermanfaat.

Implementasi ekonomi syariah di Indonesia terus berkembang dengan hadirnya bank syariah, asuransi syariah, dan pasar modal syariah.
      ''',
      excerpt: 'Ekonomi syariah menawarkan sistem keuangan yang adil dan berkelanjutan berdasarkan prinsip-prinsip Islam.',
      photo: '/placeholder.svg?height=200&width=300',
      categoryId: '3',
      authorId: '2',
      publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      views: 156,
      isPublished: true,
    ),
    Article(
      id: '4',
      title: 'Makna Jihad dalam Perspektif Muhammadiyah',
      content: '''
Jihad merupakan salah satu konsep penting dalam Islam yang sering disalahpahami. Dalam perspektif Muhammadiyah, jihad memiliki makna yang luas dan tidak terbatas pada perang fisik.

Jenis-jenis Jihad:

1. Jihad Nafs (Melawan Hawa Nafsu)
Ini adalah jihad terbesar (jihad akbar) yaitu melawan hawa nafsu dan keinginan buruk dalam diri.

2. Jihad Ilmu
Berjuang dalam menuntut dan mengamalkan ilmu pengetahuan untuk kemaslahatan umat.

3. Jihad Sosial
Berjuang melawan kemiskinan, kebodohan, dan ketidakadilan sosial.

4. Jihad Dakwah
Menyebarkan ajaran Islam dengan hikmah dan cara yang baik.

5. Jihad Ekonomi
Membangun sistem ekonomi yang adil dan mensejahterakan umat.

Muhammadiyah sebagai organisasi Islam modern mengimplementasikan jihad melalui berbagai amal usaha seperti sekolah, rumah sakit, panti asuhan, dan kegiatan sosial lainnya.
      ''',
      excerpt: 'Jihad dalam perspektif Muhammadiyah memiliki makna luas yang mencakup berbagai aspek kehidupan untuk kemaslahatan umat.',
      photo: '/placeholder.svg?height=200&width=300',
      categoryId: '4',
      authorId: '1',
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      views: 203,
      isPublished: true,
    ),
    Article(
      id: '5',
      title: 'Peran Teknologi dalam Pendidikan Modern',
      content: '''
Era digital telah mengubah paradigma pendidikan secara fundamental. Teknologi tidak lagi menjadi pelengkap, tetapi kebutuhan utama dalam proses pembelajaran modern.

Manfaat Teknologi dalam Pendidikan:

1. Akses Informasi yang Luas
Internet memberikan akses tak terbatas terhadap sumber belajar dari seluruh dunia.

2. Pembelajaran Interaktif
Media digital memungkinkan pembelajaran yang lebih menarik dan interaktif.

3. Personalisasi Pembelajaran
Teknologi memungkinkan penyesuaian metode belajar sesuai kebutuhan individual siswa.

4. Efisiensi Waktu dan Biaya
E-learning mengurangi biaya transportasi dan memungkinkan belajar kapan saja.

5. Kolaborasi Global
Siswa dapat berkolaborasi dengan teman dari berbagai negara melalui platform digital.

Tantangan yang perlu diatasi meliputi kesenjangan digital, kualitas konten, dan kemampuan guru dalam menggunakan teknologi.
      ''',
      excerpt: 'Teknologi telah mengubah paradigma pendidikan modern dengan memberikan akses informasi yang luas dan pembelajaran interaktif.',
      photo: '/placeholder.svg?height=200&width=300',
      categoryId: '1',
      authorId: '3',
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      views: 98,
      isPublished: true,
    ),
    Article(
      id: '6',
      title: 'Manajemen Stress dalam Islam',
      content: '''
Stress merupakan bagian dari kehidupan modern yang tidak dapat dihindari. Islam memberikan panduan komprehensif untuk mengelola stress dengan cara yang sehat dan produktif.

Cara Mengelola Stress dalam Islam:

1. Dzikir dan Doa
"Ingatlah, hanya dengan mengingat Allah hati menjadi tenteram." (QS. Ar-Ra'd: 28)

2. Shalat sebagai Terapi
Shalat memberikan ketenangan jiwa dan mendekatkan diri kepada Allah.

3. Sabar dan Tawakal
Bersabar dalam menghadapi cobaan dan bertawakal kepada Allah.

4. Silaturahmi
Menjaga hubungan baik dengan sesama dapat mengurangi beban psikologis.

5. Istighfar
Memohon ampun kepada Allah dapat memberikan ketenangan hati.

6. Olahraga dan Aktivitas Positif
Islam menganjurkan aktivitas fisik yang sehat untuk menjaga keseimbangan jiwa dan raga.

Dengan mengamalkan ajaran Islam, umat Muslim dapat mengelola stress dengan lebih baik dan menjalani hidup yang lebih berkualitas.
      ''',
      excerpt: 'Islam memberikan panduan komprehensif untuk mengelola stress melalui dzikir, doa, sabar, dan aktivitas positif.',
      photo: '/placeholder.svg?height=200&width=300',
      categoryId: '2',
      authorId: '2',
      publishedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      views: 67,
      isPublished: true,
    ),
  ];

  // Tickets
  static final List<Ticket> tickets = [
    Ticket(
      id: '1',
      userId: '1',
      categoryId: '1',
      title: 'Usulan Program Beasiswa untuk Anak Yatim',
      description: 'Saya mengusulkan adanya program beasiswa khusus untuk anak-anak yatim di lingkungan Muhammadiyah. Program ini dapat membantu mereka melanjutkan pendidikan hingga jenjang yang lebih tinggi.',
      photo: '/placeholder.svg?height=200&width=300',
      status: 'approved',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      adminNote: 'Usulan yang sangat baik. Akan dibahas dalam rapat pengurus.',
    ),
    Ticket(
      id: '2',
      userId: '3',
      categoryId: '2',
      title: 'Klinik Kesehatan Gratis di Daerah Terpencil',
      description: 'Mengusulkan pembukaan klinik kesehatan gratis di daerah terpencil yang belum terjangkau fasilitas kesehatan. Banyak masyarakat yang kesulitan akses ke pelayanan kesehatan.',
      photo: '/placeholder.svg?height=200&width=300',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      adminNote: null,
    ),
    Ticket(
      id: '3',
      userId: '1',
      categoryId: '3',
      title: 'Koperasi Syariah untuk UMKM',
      description: 'Proposal pembentukan koperasi syariah yang dapat membantu UMKM dalam mengembangkan usaha mereka dengan sistem yang sesuai syariat Islam.',
      status: 'rejected',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      adminNote: 'Perlu kajian lebih mendalam terkait aspek legalitas dan operasional.',
    ),
    Ticket(
      id: '4',
      userId: '3',
      categoryId: '4',
      title: 'Program Tahfidz untuk Remaja',
      description: 'Mengusulkan program tahfidz Al-Quran khusus untuk remaja dengan metode yang menyenangkan dan sesuai dengan perkembangan zaman.',
      photo: '/placeholder.svg?height=200&width=300',
      status: 'approved',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      adminNote: 'Program yang sangat dibutuhkan. Akan segera diimplementasikan.',
    ),
  ];

  // Helper methods
  static User? getUserById(String id) {
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  static Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Article> getArticlesByCategory(String categoryId) {
    return articles.where((article) => article.categoryId == categoryId).toList();
  }

  static List<Article> getArticlesByAuthor(String authorId) {
    return articles.where((article) => article.authorId == authorId).toList();
  }

  static List<Ticket> getTicketsByUser(String userId) {
    return tickets.where((ticket) => ticket.userId == userId).toList();
  }

  static List<Ticket> getTicketsByStatus(String status) {
    return tickets.where((ticket) => ticket.status == status).toList();
  }
}
