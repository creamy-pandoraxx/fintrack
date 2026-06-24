\# PRD — FinTrack



\## 1. Product Name



FinTrack



\## 2. Product Type



Full-stack mobile personal finance tracker application.



\## 3. Project Purpose



FinTrack adalah aplikasi pencatat keuangan pribadi yang dibuat sebagai proyek portofolio mobile development. Project ini dirancang untuk menunjukkan kemampuan dalam membangun aplikasi mobile modern menggunakan Flutter, backend REST API, SQL database, NoSQL database, authentication, dan clean architecture.



Aplikasi ini membantu pengguna mencatat pemasukan, pengeluaran, dompet/akun keuangan, kategori transaksi, budget bulanan, serta melihat ringkasan kondisi keuangan secara sederhana dan mudah dipahami.



\## 4. Product Vision



FinTrack ingin menjadi aplikasi pencatat keuangan pribadi yang ringan, modern, dan mudah digunakan. Aplikasi ini tidak mencoba menjadi aplikasi banking atau accounting yang kompleks. Fokus utamanya adalah membantu pengguna memahami ke mana uang mereka pergi, berapa pemasukan dan pengeluaran mereka, serta bagaimana kondisi budget bulanan mereka.



\## 5. Problem Statement



Banyak orang kesulitan mengelola uang karena tidak memiliki kebiasaan mencatat transaksi harian. Pengeluaran kecil sering tidak terasa, tetapi jika dikumpulkan dalam satu bulan bisa menjadi besar. Aplikasi pencatat keuangan yang ada terkadang terlalu kompleks, terlalu penuh fitur, atau kurang nyaman digunakan untuk kebutuhan sederhana.



FinTrack menyelesaikan masalah ini dengan menyediakan aplikasi mobile yang fokus pada pencatatan keuangan harian, pengelompokan kategori, pengelolaan dompet, budget bulanan, dan dashboard visual yang mudah dipahami.



\## 6. Target Users



\### Primary Users



\- Mahasiswa

\- Fresh graduate

\- Pekerja awal karier

\- Freelancer

\- Pengguna umum yang ingin mulai mengatur keuangan pribadi



\### User Characteristics



\- Menggunakan smartphone sebagai perangkat utama.

\- Ingin mencatat pemasukan dan pengeluaran secara manual.

\- Tidak membutuhkan integrasi bank.

\- Membutuhkan dashboard sederhana.

\- Ingin mengetahui kategori pengeluaran terbesar.

\- Ingin mengontrol budget bulanan.

\- Menyukai aplikasi yang clean, cepat, dan tidak membingungkan.



\## 7. User Goals



Pengguna ingin:



1\. Mencatat pemasukan dan pengeluaran dengan cepat.

2\. Mengelola beberapa dompet atau akun keuangan.

3\. Mengelompokkan transaksi berdasarkan kategori.

4\. Mengetahui total saldo.

5\. Melihat pemasukan dan pengeluaran bulanan.

6\. Membuat budget per kategori.

7\. Mengetahui apakah pengeluaran sudah mendekati batas budget.

8\. Melihat ringkasan keuangan dalam bentuk dashboard.

9\. Mendapat insight sederhana tentang kebiasaan keuangan.



\## 8. Business/Product Goals



Tujuan produk:



1\. Membuat aplikasi mobile finance tracker yang layak menjadi portofolio.

2\. Menunjukkan kemampuan Flutter mobile development.

3\. Menunjukkan kemampuan REST API integration.

4\. Menunjukkan kemampuan backend development.

5\. Menunjukkan kemampuan SQL database design.

6\. Menunjukkan penggunaan NoSQL database yang relevan.

7\. Menunjukkan authentication flow yang modern.

8\. Menunjukkan clean architecture dan maintainable code.

9\. Menunjukkan kemampuan membangun dashboard dan visualisasi data.

10\. Membuat project yang bisa dijelaskan dengan kuat saat interview kerja.



\## 9. MVP Scope



\### Must Have Features



\#### 9.1 Authentication



Pengguna dapat:



\- Register menggunakan email dan password.

\- Login menggunakan email dan password.

\- Logout.

\- Tetap login setelah aplikasi dibuka ulang.

\- Mengakses data miliknya sendiri secara aman.



Authentication menggunakan Firebase Authentication. Backend memverifikasi Firebase ID Token menggunakan Firebase Admin SDK.



\#### 9.2 User Profile



Pengguna dapat:



\- Melihat nama dan email.

\- Mengubah nama profil.

\- Memiliki data profile yang tersinkron dengan backend.



\#### 9.3 Wallet Management



Pengguna dapat:



\- Membuat wallet/dompet.

\- Melihat daftar wallet.

\- Mengubah wallet.

\- Menghapus atau mengarsipkan wallet.

\- Melihat saldo setiap wallet.

\- Melihat total saldo dari semua wallet.



Contoh wallet:



\- Cash

\- Bank

\- E-wallet

\- Savings

\- Other



\#### 9.4 Category Management



Pengguna dapat:



\- Melihat kategori income dan expense.

\- Mendapat default categories saat pertama kali register.

\- Membuat custom category.

\- Mengubah category.

\- Menghapus category jika belum digunakan transaksi.



Default expense categories:



\- Food

\- Transport

\- Shopping

\- Bills

\- Health

\- Education

\- Entertainment

\- Other



Default income categories:



\- Salary

\- Freelance

\- Gift

\- Investment

\- Other



\#### 9.5 Transaction Management



Pengguna dapat:



\- Menambahkan income transaction.

\- Menambahkan expense transaction.

\- Melihat daftar transaksi.

\- Mengubah transaksi.

\- Menghapus transaksi.

\- Memfilter transaksi berdasarkan:

&#x20; - type

&#x20; - wallet

&#x20; - category

&#x20; - date range

&#x20; - search keyword



Data transaksi wajib memiliki:



\- Type: INCOME atau EXPENSE

\- Amount

\- Wallet

\- Category

\- Title

\- Note optional

\- Transaction date



\#### 9.6 Dashboard



Dashboard harus menampilkan:



\- Total balance

\- Monthly income

\- Monthly expense

\- Net cash flow

\- Expense breakdown by category

\- Budget usage summary

\- Recent transactions

\- Finance tip

\- Activity feed preview



\#### 9.7 Budget Management



Pengguna dapat:



\- Membuat budget bulanan per kategori expense.

\- Melihat jumlah budget.

\- Melihat jumlah yang sudah terpakai.

\- Melihat sisa budget.

\- Melihat persentase penggunaan budget.

\- Mengubah budget.

\- Menghapus budget.



Rules:



\- Budget hanya untuk category type EXPENSE.

\- Satu kategori hanya boleh memiliki satu budget pada bulan dan tahun yang sama.



\#### 9.8 Firestore Activity Feed



Firestore digunakan untuk menyimpan activity feed realtime.



Contoh activity:



\- Added expense: Food - Rp50.000

\- Updated transaction: Lunch

\- Deleted transaction

\- Created budget: Transport



Activity feed hanya menyimpan summary, bukan full financial data.



\#### 9.9 Finance Tips



Firestore digunakan untuk menyimpan finance tips yang bisa ditampilkan di dashboard.



Contoh:



\- “Track small expenses because they can become large monthly spending.”

\- “Set a budget for your biggest expense category first.”



\## 10. Nice To Have Features



Fitur berikut tidak wajib untuk MVP, tetapi bisa ditambahkan setelah MVP stabil:



1\. Saving goals.

2\. Recurring transactions.

3\. CSV export.

4\. Dark mode.

5\. PIN or biometric lock.

6\. Push notification.

7\. Offline cache.

8\. Multi-currency.

9\. Receipt photo upload.

10\. Monthly report PDF.



\## 11. Out of Scope



Fitur berikut tidak dikerjakan dalam MVP:



1\. Bank account integration.

2\. Payment gateway.

3\. E-wallet direct sync.

4\. Investment tracking.

5\. Tax calculation.

6\. Multi-user shared wallet.

7\. AI financial advisor.

8\. Cryptocurrency tracking.

9\. Real money transfer.

10\. Complex accounting system.



\## 12. Main User Flows



\### 12.1 Register Flow



1\. User membuka aplikasi.

2\. User melihat welcome screen.

3\. User memilih register.

4\. User mengisi name, email, password, dan confirm password.

5\. Firebase Authentication membuat akun.

6\. Mobile app mengambil Firebase ID Token.

7\. Mobile app mengirim request ke backend `/auth/sync`.

8\. Backend memverifikasi token.

9\. Backend membuat user profile di PostgreSQL.

10\. Backend membuat default categories.

11\. User masuk ke dashboard.



\### 12.2 Login Flow



1\. User membuka aplikasi.

2\. User memilih login.

3\. User memasukkan email dan password.

4\. Firebase Authentication memverifikasi login.

5\. Mobile app mengambil Firebase ID Token.

6\. Mobile app memanggil backend `/users/me`.

7\. Backend memverifikasi token.

8\. User masuk ke dashboard.



\### 12.3 Add Expense Flow



1\. User membuka dashboard.

2\. User menekan tombol add transaction.

3\. User memilih type EXPENSE.

4\. User mengisi amount, wallet, category, date, dan title.

5\. User menekan save.

6\. Mobile app mengirim request ke backend.

7\. Backend validasi data.

8\. Backend menyimpan transaksi ke PostgreSQL.

9\. Backend mengurangi wallet balance.

10\. Backend membuat activity feed di Firestore.

11\. App refresh dashboard dan transaction list.



\### 12.4 Add Income Flow



1\. User membuka add transaction screen.

2\. User memilih type INCOME.

3\. User memilih wallet dan category income.

4\. User mengisi amount, title, dan date.

5\. Backend menyimpan transaksi.

6\. Backend menambah wallet balance.

7\. Activity feed dibuat.



\### 12.5 Create Budget Flow



1\. User membuka budget screen.

2\. User memilih month dan year.

3\. User memilih expense category.

4\. User mengisi limit amount.

5\. Backend menyimpan budget.

6\. Dashboard menampilkan budget usage.



\### 12.6 View Dashboard Flow



1\. User membuka dashboard.

2\. Mobile app memanggil `/dashboard/summary`.

3\. Backend menghitung summary dari PostgreSQL.

4\. Mobile app menampilkan card, chart, budget progress, dan recent transactions.

5\. Mobile app membaca activity feed dan finance tips dari Firestore.



\## 13. Screen Requirements



\### 13.1 Splash Screen



Purpose:



\- Mengecek auth state.

\- Redirect user ke welcome/login atau dashboard.



Components:



\- Logo atau app name.

\- Loading indicator.



Behavior:



\- Jika user sudah login, ambil Firebase ID Token dan arahkan ke dashboard.

\- Jika user belum login, arahkan ke welcome screen.



\### 13.2 Welcome Screen



Components:



\- App name: FinTrack

\- Tagline: Track your money. Understand your habits.

\- Button: Get Started

\- Button: Login



\### 13.3 Register Screen



Fields:



\- Name

\- Email

\- Password

\- Confirm password



Validation:



\- Name required.

\- Email valid.

\- Password minimum 8 characters.

\- Confirm password harus sama dengan password.



\### 13.4 Login Screen



Fields:



\- Email

\- Password



Validation:



\- Email required.

\- Password required.



\### 13.5 Dashboard Screen



Components:



\- Greeting text.

\- Total balance card.

\- Monthly income card.

\- Monthly expense card.

\- Net cash flow card.

\- Expense breakdown chart.

\- Budget progress section.

\- Recent transactions list.

\- Finance tip card.

\- Activity feed preview.

\- Floating action button for add transaction.



\### 13.6 Transaction List Screen



Components:



\- Transaction list.

\- Search field.

\- Filter chips.

\- Date grouping.

\- Empty state.

\- Loading state.

\- Error state.



Each transaction item shows:



\- Category icon.

\- Transaction title.

\- Wallet name.

\- Date.

\- Amount.

\- Type indicator.



\### 13.7 Add/Edit Transaction Screen



Fields:



\- Type: INCOME or EXPENSE

\- Amount

\- Wallet

\- Category

\- Date

\- Title

\- Note optional



Validation:



\- Amount required and greater than 0.

\- Wallet required.

\- Category required.

\- Date required.

\- Category type must match transaction type.



\### 13.8 Wallet Screen



Components:



\- List of wallets.

\- Total balance.

\- Add wallet button.



Wallet fields:



\- Name

\- Type

\- Initial balance

\- Currency



\### 13.9 Category Screen



Components:



\- Income category tab.

\- Expense category tab.

\- Add category button.



Category fields:



\- Name

\- Type

\- Icon

\- Color



\### 13.10 Budget Screen



Components:



\- Month selector.

\- Budget list.

\- Progress bar.

\- Used amount.

\- Remaining amount.

\- Usage percentage.



Budget fields:



\- Month

\- Year

\- Expense category

\- Limit amount



\### 13.11 Activity Feed Screen



Data source:



\- Firestore



Components:



\- Activity list.

\- Realtime update.

\- Empty state.



\### 13.12 Profile/Settings Screen



Components:



\- User name

\- Email

\- Edit profile

\- Manage categories

\- Logout

\- App version



\## 14. UX Requirements



The app should feel:



\- Clean

\- Modern

\- Fast

\- Simple

\- Professional

\- Mobile-first



UX principles:



1\. Add transaction must be fast.

2\. Dashboard must be understandable within 5 seconds.

3\. Error messages must be clear.

4\. Empty states must guide the user.

5\. Loading states must be visible.

6\. Forms must be easy to complete.

7\. Financial numbers must be readable.

8\. Navigation must be simple.



\## 15. Acceptance Criteria



\### Authentication



\- User can register.

\- User can login.

\- User can logout.

\- User session persists.

\- Backend rejects invalid token.

\- Backend rejects missing token.



\### Wallet



\- User can create wallet.

\- User can see wallet list.

\- User can edit wallet.

\- User can archive/delete wallet.

\- Wallet balance updates after transaction.

\- User cannot access another user's wallet.



\### Category



\- New user receives default categories.

\- User can create custom category.

\- User can filter categories by type.

\- User cannot delete category that has transactions.



\### Transaction



\- User can create income transaction.

\- User can create expense transaction.

\- User can edit transaction.

\- User can delete transaction.

\- Wallet balance changes correctly.

\- Transaction list supports filters.

\- Form prevents invalid input.



\### Budget



\- User can create monthly budget.

\- User can edit budget.

\- User can delete budget.

\- Budget usage is calculated correctly.

\- Duplicate budget for same category/month/year is rejected.



\### Dashboard



\- Dashboard shows total balance.

\- Dashboard shows monthly income.

\- Dashboard shows monthly expense.

\- Dashboard shows net cash flow.

\- Dashboard shows expense breakdown.

\- Dashboard shows budget usage.

\- Dashboard shows recent transactions.



\### Firestore



\- Activity feed is created after transaction changes.

\- User only sees their own activity feed.

\- Finance tips can be displayed on dashboard.



\## 16. Portfolio Value



FinTrack should be presented as a portfolio project that demonstrates:



\- Flutter mobile development.

\- Full-stack app architecture.

\- REST API integration.

\- PostgreSQL relational database design.

\- Firebase Authentication.

\- Firestore NoSQL usage.

\- State management with Riverpod.

\- Backend development with Express TypeScript.

\- Prisma ORM.

\- Clean code and maintainable structure.

\- Dashboard and data visualization.

