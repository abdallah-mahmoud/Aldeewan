# 📱 تطبيق الديوان (Aldeewan Mobile)

<p align="center">
  <img src="assets/images/logo.png" alt="Aldeewan Logo" width="120" />
</p>

<p align="center">
  <b>نظام محاسبي ذكي وشامل لإدارة الديون والمصروفات والإيرادات</b>
  <br>
  <i>مصمم بتقنيات حديثة وواجهة عصرية لتجربة مستخدم فائقة</i>
</p>

---

## 📋 نبذة عن المشروع

**تطبيق الديوان** هو حل تقني متكامل يهدف إلى تسهيل الإدارة المالية للأفراد والشركات الصغيرة. يتيح التطبيق للمستخدمين تتبع الديون (لنا وعلينا)، تسجيل المصروفات والإيرادات اليومية، وإصدار تقارير مالية دقيقة. تم إعادة تصميم التطبيق بالكامل (V3) ليواكب أحدث صيحات تصميم تطبيقات التكنولوجيا المالية (Fintech) مع التركيز على البساطة، الأمان، وسرعة الأداء.

## ✨ المميزات الرئيسية

### 1. 📊 لوحة تحكم شاملة (Dashboard)
- عرض فوري للموقف المالي: إجمالي الديون (لنا/علينا)، الرصيد الحالي، وصافي الثروة.
- رسوم بيانية تفاعلية (Charts) لتحليل حركة الأموال والمصروفات.
- وصول سريع للعمليات الأكثر استخداماً.

### 2. 📒 الدفتر (Ledger)
- إدارة حسابات العملاء والموردين.
- تسجيل عمليات البيع والشراء الآجل بدقة.
- تتبع سجل المعاملات لكل عميل مع كشف حساب تفصيلي.

### 3. 💰 الصندوق (Cashbook)
- تسجيل حركات النقدية اليومية (إيرادات ومصروفات).
- تصنيف المعاملات (فئات المصروفات والإيرادات) لتحليل الإنفاق.

### 4. 📈 التقارير والتصدير
- تقارير مالية مفصلة بصيغة PDF و CSV.
- كشوفات حساب للعملاء والموردين قابلة للمشاركة.

### 5. 🔐 الأمان والخصوصية
- تخزين البيانات محلياً (Local-First) لضمان الخصوصية الكاملة.
- دعم الدخول البيومتري (بصمة الإصبع/الوجه) لحماية التطبيق.
- تشفير البيانات الحساسة باستخدام تقنيات آمنة.

### 6. 🎨 واجهة مستخدم عصرية (UI/UX)
- تصميم "Fintech" حديث يعتمد على البساطة والوضوح.
- دعم الوضع الليلي (Dark Mode) والوضع النهاري.
- دعم كامل للغة العربية (RTL) باستخدام خط "Cairo" المميز.

---

## 🛠 البنية التقنية (Architecture)

يعتمد المشروع على **Clean Architecture** لضمان قابلية التوسع، سهولة الاختبار، وفصل المسؤوليات.

### طبقات المشروع:
1.  **Presentation Layer (`lib/presentation`):**
    - تحتوي على واجهات المستخدم (Screens & Widgets).
    - إدارة الحالة باستخدام **Riverpod**.
2.  **Domain Layer (`lib/domain`):**
    - تحتوي على قواعد العمل (Entities & Use Cases).
    - واجهات المستودعات (Repository Interfaces).
    - هذه الطبقة معزولة تماماً عن أي تفاصيل تقنية خارجية.
3.  **Data Layer (`lib/data`):**
    - تنفيذ المستودعات (Repository Implementations).
    - مصادر البيانات (Data Sources) والتعامل مع قاعدة البيانات المحلية.

---

## 🧰 التقنيات والمكتبات المستخدمة

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [Riverpod](https://riverpod.dev/) - لإدارة حالة التطبيق بطريقة تفاعلية وآمنة.
- **Database:** [Realm](https://realm.io/) - قاعدة بيانات محلية سريعة جداً وحديثة.
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router) - لإدارة التنقل بين الشاشات والروابط العميقة.
- **Charts:** [fl_chart](https://pub.dev/packages/fl_chart) - للرسوم البيانية والإحصائيات.
- **Security:**
    - `flutter_secure_storage`: لتخزين المفاتيح والبيانات الحساسة.
    - `local_auth`: للمصادقة البيومترية.
- **UI Assets:**
    - `google_fonts`: استخدام خط Cairo.
    - `lucide_icons`: أيقونات عصرية وخفيفة.
- **Utilities:** `intl`, `share_plus`, `file_picker`, `path_provider`.

---

## 📂 هيكلة المشروع

```
lib/
├── config/          # إعدادات التطبيق (الثيمات، الراوتر، الثوابت)
├── data/            # طبقة البيانات (Realm Models, Repositories Impl)
├── domain/          # طبقة النطاق (Entities, UseCases, Repos Interfaces)
├── l10n/            # ملفات الترجمة (Ar, En)
├── presentation/    # طبقة العرض (Screens, Widgets, Providers)
├── utils/           # دوال مساعدة وأدوات عامة
└── main.dart        # نقطة انطلاق التطبيق
```

---

## 🚀 بدء الاستخدام (Getting Started)

### المتطلبات
- Flutter SDK (الإصدار 3.2.3 أو أحدث)
- Dart SDK
- Android Studio / VS Code

### خطوات التثبيت

1.  **استنساخ المستودع:**
    ```bash
    git clone https://github.com/abdallah-mahmoud/Aldeewan-Mobile.git
    cd Aldeewan-Mobile
    ```

2.  **تثبيت المكتبات:**
    ```bash
    flutter pub get
    ```

3.  **توليد ملفات الكود (Code Generation):**
    بما أننا نستخدم Realm و Riverpod، نحتاج لتوليد بعض الملفات:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **تشغيل التطبيق:**
    ```bash
    flutter run
    ```

---

## 🤝 المساهمة

نرحب بمساهماتكم لتطوير التطبيق! يرجى اتباع الخطوات التالية:
1.  قم بعمل Fork للمشروع.
2.  أنشئ فرعاً جديداً لميزتك (`git checkout -b feature/AmazingFeature`).
3.  قم بعمل Commit لتغييراتك (`git commit -m 'Add some AmazingFeature'`).
4.  ارفع التغييرات إلى الفرع (`git push origin feature/AmazingFeature`).
5.  افتح Pull Request.

---

## 📄 الرخصة

هذا المشروع مرخص بموجب رخصة [MIT](LICENSE).

---

<p align="center">
  تم التطوير بكل ❤️ بواسطة فريق الديوان
</p>
