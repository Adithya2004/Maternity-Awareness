import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Usermodel {
  final String? id;
  final String firstname;
  final String lastname;
  final String email;
  final int age;
  final int week;
  final bool due;

  const Usermodel({
    this.id,
    required this.age,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.week,
    required this.due,
  });

  toJson() {
    return {
      "First_name": firstname,
      "Last_name": lastname,
      "Email": email,
      "Age": age,
      "Current_week": week,
      "Due": due,
    };
  }

  factory Usermodel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Usermodel(
      id: document.id,
      age: data["Age"],
      email: data["Email"],
      firstname: data["First_name"],
      lastname: data["Last_name"],
      week: data["Current_week"],
      due: data["Due"],
    );
  }
}

class UserRepository {
  //static UserRepository get instance => Get.find();
  final db = FirebaseFirestore.instance;
  //store user in firebase
  createUser(Usermodel user) async {
    await db.collection("users").add(user.toJson());
  }

  //Fetch all  details from firebase
  Future<Usermodel> getUserDetails(String email) async {
    final snapshot =
        await db.collection("users").where("Email", isEqualTo: email).get();
    final userData = snapshot.docs.map((e) => Usermodel.fromSnapshot(e)).single;
    return userData;
  }

  //Update
  Future<void> updateUserRecord(Usermodel user) async {
    var a =
        await FirebaseFirestore.instance.collection("users").doc(user.id).get();
    if (a.exists) {
      final DocumentReference documentReference =
          FirebaseFirestore.instance.collection("users").doc(user.id);
      return await documentReference.update(user.toJson());
    } else {
      final DocumentReference documentReference =
          FirebaseFirestore.instance.collection("users").doc(user.id);
      return await documentReference.set(user.toJson());
    }
  }
}

// ignore: use_key_in_widget_constructors
class MyHomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    DashboardPage(),
    ExercisePage(),
    NutritionPage(),
    ProfileScreen(),
  ];
  Future<User?> getuser() async {
    return FirebaseAuth.instance.currentUser;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 152, 185),
      body: SafeArea(
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.blueAccent,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(Icons.fitness_center),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(Icons.restaurant_menu),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.grey,
            icon: Icon(Icons.info),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class DashboardPage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  final userRepo = UserRepository();
  getUserData() {
    final email = user!.email!;
    return userRepo.getUserDetails(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 152, 185),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                Usermodel userData = snapshot.data as Usermodel;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Dashboard Page',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hello ",
                            style: TextStyle(fontSize: 24),
                          ),
                          Text(
                            userData.firstname,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      child: userData.due
                          ? const Center(
                              child: Text(
                                "DUE",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              ),
                            )
                          : const Center(
                              child: Text(
                                "NOT DUE",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: Text("Something went Wrong!!"),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class ExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Month-wise Exercises:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'It is important to engage in regular exercise throughout pregnancy to maintain fitness and prepare for childbirth. Here are some exercises you can do each month:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(
            height: 16,
          ),

          Text(
              "During pregnancy, exercise works wonder for both you and your baby. Exercise under the guidance of a trained supervisor helps you to gain confidence and stability during pregnancy.Our different exercise sessions help you tune your body well with pregnancy. We believe exercise is not just a single parent role, it involves the couple. So we train expecting dads also to help and support their partner during exercise sessions. Exercise during pregnancy is highly recommended by experts to have a healthier and happier pregnancy. Starting with pranayama, moving to other beautiful breathing exercise, learn to control and calm the mind as you go through your pregnancy. Meditation and relaxation techniques, Stress Management & relaxation techniques, Breathing patterns, Association of breathing with labour."),
          SizedBox(height: 16),
          Text(
              "It's important for pregnant women to consult with their healthcare provider before starting any exercise routine, but there are several safe exercises that can be done during all three trimesters of pregnancy. Here are some examples:"),

          Text(
              "Walking: A low-impact exercise that can be done throughout pregnancy, walking is a great way to stay active and improve cardiovascular health."),
          SizedBox(height: 8),
          Text(
              "Swimming: Swimming is a low-impact exercise that is easy on the joints and can help reduce swelling and discomfort."),
          SizedBox(height: 8),
          Text(
              "Prenatal yoga: Yoga can help improve flexibility, balance, and strength, as well as reduce stress and anxiety."),
          SizedBox(height: 8),
          Text(
              "Low-impact aerobics: Low-impact aerobics, such as dancing or using an elliptical machine, can help improve cardiovascular health and increase endurance."),
          SizedBox(height: 8),
          Text(
              "Kegels: Kegel exercises can help strengthen the pelvic floor muscles, which can help with urinary incontinence and prepare for childbirth."),
          SizedBox(height: 8),
          Text(
              "It's important to listen to your body and avoid exercises that cause discomfort or pain. Pregnant women should also avoid exercises that involve lying flat on their back after the first trimester, as this can put pressure on the vena cava, a large vein that can affect blood flow to the fetus."),

          SizedBox(height: 8),
          Text(
            "FAQ",
            style: TextStyle(
              fontSize: 30,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text("Q1 how much exercise should I do during pregnancy?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "We suggest a 30 min relaxing exercise should be enough to have a healthy baby. You don’t have to be exhausted by exercise to benefit from it. The goal is to build up to and keep a good level of fitness throughout your pregnancy."),
          Text("Q2 Are there any risk of exercise while I am pregnant?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "We don't say that there are no risks at all. All women who exercise while pregnant should seek advice from their doctor or expert to ensure they are not overdoing it or engaging in specific activities that should be avoided."),

          Text("Q3 what are the best cardio exercise for pregnant ladies?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "Cardiovascular exercises such as walking, swimming, jogging, and stationary cycling are top picks during all three trimesters. Unless your doctor has told you to modify physical activity, you can join online exercise sessions and have a healthy pregnancy journey. "),

          Text(
              "Q4 what are the best strength and flexibility exercises that I can do ?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "This is a great time to focus on cardiovascular activities and keep up your mobility and abdominal strength with walking, swimming, prenatal yoga, pelvic floor exercises, bodyweight moves."),
          SizedBox(
            height: 10,
          ),
          Text("Correct breathing practice during pregnancy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "Starting with pranayam, moving to other beautiful breathing exercises, learn the art to control and calm the mind as you go through your pregnancy.We prepare you to breath and control your anxiety during pregnancy. We make sure that this phase becomes the most memorable and most enjoyable moment of your life."),
          Text("Q1 how to manage my stress during pregnancy?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "One of the most common problems women go through during pregnancy is stress. You can easily manage the stress by meditating, paying attention on your breath and control yourself too . We will  train you well of all breathing techniques that can help you to come up with stress during pregnancy."),

          Text("Q2 what is parental care?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "Prenatal care is the health care you get while you are pregnant. Take care of yourself and your baby."),
          Text("Q3 How often should I see my doctor during pregnancy?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "Your doctor will give you a schedule of all the doctor's visits you should have while pregnant. Most experts suggest you see your doctor:"),
          Text("•	About once each month for weeks 4 through 28"),
          Text("•	Twice a month for weeks 28 through 36"),
          Text("•	Weekly for weeks 36 to birth"),
          Text(
              "If you are older than 35 or your pregnancy is high risk, you'll probably see your doctor more often. "),
          Text("Q4 What happens during parental visit?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "During the first prenatal visit, you can expect your doctor to:"),
          Text(
              "•	Ask about your health history including diseases, operations, or prior pregnancies"),
          Text("•	Ask about your family's health history "),
          Text(
              "•	Do a complete physical exam, including a pelvic exam and Pap test "),
          Text("•	Take your blood and urine for lab work "),
          Text("•	Check your blood pressure, height, and weight "),
          Text("•	Calculate your due date"),
          Text("•	Answer your questions"),
          Text(
              "At the first visit, you should ask questions and discuss any issues related to your pregnancy. Find out all you can about how to stay healthy. "),
          Text("Q5 How will I know when labor has started?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "Some of the signs and symptoms of going into labor may include: period-like cramps, backache, diarrhoea, a small bloodstained discharge. As your cervix thins and the mucus plug drops out, a gush or trickle of water as the membranes break and Contractions start."),
          Text("Q6 What are stages of labor?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("There are 3 stages of Labor:"),
          Text("First Stage – dilation of the cervix"),
          Text("Second Stage – fully dilated till expulsion of the foetus"),
          Text(
              "Third stage – following expulsion of the foetus till the placenta and membranes are delivered."),
          Text("Q7 How can I prepare myself before going to labor?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(
              "Using breathing techniques can help calm your nerves (before and after labor) and control the pain. You can practise all the way through pregnancy to ensure you’re comfortable using them when labor starts"),

//           Image.asset('assets/exercises/third_trimester.png'),
        ],
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class NutritionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 152, 185),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Month-wise Food Chart:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Eating a balanced and nutritious diet is important during pregnancy to support the growth and development of the baby. Here is a month-wise food chart to follow:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'First Trimester (Months 1-3):',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("Monday", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Breakfast: Greek yogurt with mixed berries and granola"),
            Text("Snack: Apple slices with almond butter"),
            Text(
                "Lunch: Grilled chicken salad with mixed greens, avocado, and a vinaigrette dressing"),
            Text("Snack: Trail mix with nuts and dried fruit"),
            Text(
                "Dinner: Baked salmon with roasted sweet potatoes and steamed broccoli"),
            SizedBox(height: 8),
            Text("Tuesday", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Scrambled eggs with spinach and whole grain toast, and a glass of orange juice"),
            Text("Snack: Baby carrots with hummus"),
            Text(
                "Lunch: Grilled chicken wrap with lettuce, tomato, avocado, and a side of fruit salad"),
            Text("Snack: Greek yogurt with sliced banana and honey"),
            Text("Dinner: Vegetarian chili with cornbread and a side salad"),
            SizedBox(height: 8),
            Text("Wednesday", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Whole grain waffles with fresh fruit and a dollop of whipped cream, and a glass of milk"),
            Text("Snack: Cheese and whole grain crackers"),
            Text(
                "Lunch: Quinoa salad with chickpeas, cucumber, tomatoes, and a lemon vinaigrette dressing"),
            Text("Snack: Banana with almond butter"),
            Text(
                "Dinner: Baked chicken with roasted Brussels sprouts and a baked sweet potato"),
            SizedBox(height: 8),
            Text("Thursday", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Greek yogurt parfait with granola and mixed berries, and a glass of orange juice"),
            Text("Snack: Popcorn and a piece of fruit"),
            Text("Lunch: Grilled salmon with brown rice and roasted asparagus"),
            Text(
                "Snack: Smoothie with mixed berries, spinach, and Greek yogurt"),
            Text(
                "Dinner: Baked sweet potato with black beans, salsa, and a side salad"),
            SizedBox(height: 8),
            Text("Friday", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Breakfast burrito with scrambled eggs, black beans, avocado, and salsa, and a glass of milk"),
            Text("Snack: Energy balls with dates and nuts"),
            Text(
                "Lunch: Turkey and cheese sandwich on whole grain bread with a side of raw veggies and hummus"),
            Text("Snack: Apple slices with cheese"),
            Text("Dinner: Spaghetti squash with meat sauce and a side salad"),
            SizedBox(height: 8),
            Text("Saturday", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Blueberry pancakes with a side of scrambled eggs and a glass of orange juice"),
            Text("Snack: Greek yogurt with mixed berries and granola"),
            Text("Lunch: Turkey and avocado wrap with a side of fruit salad"),
            Text("Snack: Trail mix with dried fruit and nuts"),
            Text("Dinner: Beef stir-fry with mixed vegetables and brown rice"),
            SizedBox(height: 8),
            Text("Sunday", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Veggie omelet with a side of whole grain toast and a glass of milk"),
            Text("Snack: Baby carrots with hummus"),
            Text(
                "Lunch: Grilled chicken Caesar salad with a side of garlic bread"),
            Text("Snack: Cottage cheese with mixed berries"),
            Text("Dinner: Lentil soup with a side salad and whole grain bread"),
            SizedBox(height: 16),
            Text(
                "Remember to drink plenty of water throughout the day to stay hydrated, and talk to your healthcare provider about any dietary concerns or restrictions you may have"),
            //           Image.asset('assets/nutrition/first_trimester.png'),
            SizedBox(height: 16),

            Text(
              'Second Trimester (Months 4-6):',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("Monday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),

            Text("Breakfast: Oatmeal with sliced banana and almonds"),
            Text("Snack: Greek yogurt with berries"),
            Text(
                "Lunch: Grilled chicken salad with mixed greens, avocado, and cherry tomatoes"),
            Text("Snack: Apple slices with almond butter"),
            Text("Dinner: Grilled salmon with quinoa and roasted vegetables"),
            SizedBox(height: 8),
            Text("Tuesday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Scrambled eggs with spinach and whole-grain toast"),
            Text("Snack: Hummus with carrot sticks"),
            Text(
                "Lunch: Turkey sandwich on whole-grain bread with sliced cucumber and tomato"),
            Text("Snack: Pear slices with cheese"),
            Text("Dinner: Vegetarian chili with brown rice"),
            SizedBox(height: 8),
            Text("Wednesday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Breakfast: Greek yogurt with granola and mixed berries"),
            Text("Snack: Hard-boiled egg"),
            Text(
                "Lunch: Grilled chicken wrap with mixed greens, hummus, and roasted peppers"),
            Text("Snack: Banana with peanut butter"),
            Text("Dinner: Beef stir-fry with vegetables and brown rice"),
            SizedBox(height: 8),
            Text("Thursday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Whole-grain waffles with sliced strawberries and yogurt"),
            Text("Snack: Trail mix with nuts and dried fruit"),
            Text(
                "Lunch: Tuna salad with mixed greens, avocado, and cherry tomatoes"),
            Text("Snack: Orange slices"),
            Text(
                "Dinner: Baked chicken with sweet potato and steamed broccoli"),
            SizedBox(height: 8),
            Text("Friday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Smoothie with Greek yogurt, banana, and mixed berries"),
            Text("Snack: Edamame"),
            Text(
                "Lunch: Grilled shrimp salad with mixed greens, sliced cucumber, and tomato"),
            Text("Snack: Cottage cheese with peach slices"),
            Text(
                "Dinner: Pork tenderloin with roasted vegetables and brown rice"),
            SizedBox(height: 8),
            Text("Saturday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Whole-grain pancakes with blueberries and Greek yogurt"),
            Text("Snack: Almonds"),
            Text(
                "Lunch: Grilled chicken Caesar salad with whole-grain croutons"),
            Text("Snack: Sliced mango"),
            Text(
                "Dinner: Grilled steak with baked potato and roasted asparagus"),
            SizedBox(height: 8),
            Text("Sunday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Breakfast: Whole-grain toast with avocado and poached egg"),
            Text("Snack: String cheese"),
            Text("Lunch: Grilled vegetable wrap with hummus and mixed greens"),
            Text("Snack: Pineapple slices"),
            Text(
                "Dinner: Baked salmon with quinoa and roasted Brussels sprouts"),

            SizedBox(height: 8),

            //           Image.asset('assets/nutrition/second_trimester.png'),
            SizedBox(height: 16),
            Text(
              'Third Trimester (Months 7-9):',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            Text("Monday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Breakfast: Greek yogurt with granola and mixed berries"),
            Text("Snack: Baby carrots with hummus"),
            Text(
                "Lunch: Grilled chicken sandwich with whole-grain bread, avocado, and tomato"),
            Text("Snack: Orange slices"),
            Text(
                "Dinner: Baked salmon with roasted sweet potato and steamed green beans"),
            SizedBox(height: 8),
            Text("Tuesday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Breakfast: Oatmeal with sliced banana and walnuts"),
            Text("Snack: String cheese"),
            Text(
                "Lunch: Tuna salad with mixed greens, cherry tomatoes, and whole-grain crackers"),
            Text("Snack: Apple slices with almond butter"),
            Text("Dinner: Beef stir-fry with vegetables and brown rice"),
            SizedBox(height: 8),
            Text("Wednesday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Whole-grain waffles with mixed berries and Greek yogurt"),
            Text("Snack: Trail mix with nuts and dried fruit"),
            Text(
                "Lunch: Grilled chicken Caesar salad with whole-grain croutons"),
            Text("Snack: Hard-boiled egg"),
            Text("Dinner: Baked chicken with quinoa and roasted asparagus"),
            SizedBox(height: 8),
            Text("Thursday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Smoothie with Greek yogurt, banana, and mixed berries"),
            Text("Snack: Edamame"),
            Text(
                "Lunch: Grilled shrimp salad with mixed greens, sliced cucumber, and tomato"),
            Text("Snack: Pear slices with cheese"),
            Text(
                "Dinner: Pork tenderloin with roasted vegetables and brown rice"),
            SizedBox(height: 8),
            Text("Friday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Scrambled eggs with whole-grain toast and sliced avocado"),
            Text("Snack: Greek yogurt with sliced peaches"),
            Text("Lunch: Grilled vegetable wrap with hummus and mixed greens"),
            Text("Snack: Baby carrots with ranch dressing"),
            Text(
                "Dinner: Baked salmon with quinoa and roasted Brussels sprouts"),
            SizedBox(height: 8),
            Text("Saturday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Whole-grain pancakes with blueberries and Greek yogurt"),
            Text("Snack: Almonds"),
            Text(
                "Lunch: Turkey and avocado sandwich on whole-grain bread with sliced tomato"),
            Text("Snack: Cottage cheese with pineapple slices"),
            Text(
                "Dinner: Grilled steak with baked potato and steamed green beans"),
            SizedBox(height: 8),
            Text("Sunday:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
                "Breakfast: Whole-grain toast with almond butter and sliced banana"),
            Text("Snack: String cheese"),
            Text(
                "Lunch: Grilled chicken salad with mixed greens, cherry tomatoes, and avocado"),
            Text("Snack: Mango slices"),
            Text("Dinner: Vegetarian chili with brown rice and sliced avocado"),

            SizedBox(height: 8),
            //           Image.asset('assets/nutrition/third_trimester.png'),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  final userRepo = UserRepository();
  getUserData() {
    final email = user!.email!;
    return userRepo.getUserDetails(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 252, 152, 185),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    Usermodel userData = snapshot.data as Usermodel;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        const Center(
                          child: Text(
                            "PROFILE",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 44.0,
                        ),

                        //Email Id
                        Row(
                          children: [
                            const Text(
                              "Email ID :  ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userData.email,
                              style: const TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20.0,
                        ),

                        //First_name
                        Row(
                          children: [
                            const Text(
                              "First Name :  ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userData.firstname,
                              style: const TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20.0,
                        ),

                        //Last_name
                        Row(
                          children: [
                            const Text(
                              "Last Name :  ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userData.lastname,
                              style: const TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20.0,
                        ),

                        //Age
                        Row(
                          children: [
                            const Text(
                              "Age :  ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userData.age.toString(),
                              style: const TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20.0,
                        ),

                        //Current week
                        Row(
                          children: [
                            const Text(
                              "Current week:  ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userData.week.toString(),
                              style: const TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 26.0,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                                child: MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const GotoEditPage()));
                              },
                              color: Colors.blueAccent,
                              child: const Icon(Icons.edit),
                            )),
                            Center(
                              child: MaterialButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                },
                                color: Colors.blueAccent[100],
                                child: const Text(
                                  "Sign Out",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return const Center(
                      child: Text("Something went Wrong!!"),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class GotoEditPage extends StatefulWidget {
  const GotoEditPage({super.key});

  @override
  State<GotoEditPage> createState() => _GotoEditPageState();
}

class _GotoEditPageState extends State<GotoEditPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  final userRepo = UserRepository();
  getUserData() {
    final email = user!.email!;
    return userRepo.getUserDetails(email);
  }

  updateRecord(Usermodel user) async {
    await userRepo.updateUserRecord(user);
  }

  // ignore: non_constant_identifier_names

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    Usermodel userData = snapshot.data as Usermodel;
                    TextEditingController firstname1 =
                        TextEditingController(text: userData.firstname);
                    TextEditingController lastname1 =
                        TextEditingController(text: userData.lastname);
                    TextEditingController age1 =
                        TextEditingController(text: userData.age.toString());
                    TextEditingController currentweek1 =
                        TextEditingController(text: userData.week.toString());
                    return Column(
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        FocusTraversalGroup(
                          child: Form(
                              child: Column(
                            children: [
                              TextFormField(
                                controller: firstname1,
                                decoration: const InputDecoration(
                                    label: Text(
                                      "First Name",
                                    ),
                                    prefixIcon: Icon(Icons.person_2)),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              TextFormField(
                                controller: lastname1,
                                decoration: const InputDecoration(
                                    label: Text(
                                      "Last Name",
                                    ),
                                    prefixIcon: Icon(Icons.person_3_outlined)),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              TextFormField(
                                controller: age1,
                                decoration: const InputDecoration(
                                    label: Text(
                                      "Age",
                                    ),
                                    prefixIcon: Icon(Icons.numbers)),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              TextFormField(
                                controller: currentweek1,
                                decoration: const InputDecoration(
                                    label: Text(
                                      "Week",
                                    ),
                                    prefixIcon:
                                        Icon(Icons.calendar_month_outlined)),
                              ),
                              const SizedBox(
                                height: 40,
                              ),

                              //Form Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                    onPressed: () {
                                      bool due1 = userData.due;
                                      int.parse(currentweek1.text.trim()) > 30
                                          ? due1 = true
                                          : due1 = false;
                                      final userData1 = Usermodel(
                                          id: userData.id,
                                          age: int.parse(age1.text.trim()),
                                          email: userData.email,
                                          firstname: firstname1.text.trim(),
                                          lastname: lastname1.text.trim(),
                                          week: int.parse(
                                              currentweek1.text.trim()),
                                          due: due1);
                                      updateRecord(userData1);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProfileScreen()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            231, 95, 220, 0.008),
                                        side: BorderSide.none,
                                        shape: const StadiumBorder()),
                                    child: const Text(
                                      "Save Changes",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              )
                            ],
                          )),
                        )
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return const Center(
                      child: Text("Something went Wrong!!"),
                    );
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
