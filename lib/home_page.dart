import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
          SizedBox(height: 16),
          Text(
            'First Trimester (Months 1-3):',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
//           Image.asset('assets/exercises/first_trimester.png'),
          SizedBox(height: 16),
          Text(
            'Second Trimester (Months 4-6):',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
//           Image.asset('assets/exercises/second_trimester.png'),
          SizedBox(height: 16),
          Text(
            'Third Trimester (Months 7-9):',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
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
    return SingleChildScrollView(
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
          SizedBox(height: 8),
//           Image.asset('assets/nutrition/first_trimester.png'),
          SizedBox(height: 16),
          Text(
            'Second Trimester (Months 4-6):',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
//           Image.asset('assets/nutrition/second_trimester.png'),
          SizedBox(height: 16),
          Text(
            'Third Trimester (Months 7-9):',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
//           Image.asset('assets/nutrition/third_trimester.png'),
        ],
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                color: Colors.blueAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                                color: Colors.blueAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                                color: Colors.blueAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                                color: Colors.blueAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                                color: Colors.blueAccent,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 26.0,
                        ),

                        const SizedBox(
                          height: 26.0,
                        ),
                        Row(
                          children: [
                            Center(
                                child: MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GotoEditPage()));
                              },
                              color: Colors.blueAccent,
                              child: const Icon(CupertinoIcons.pencil_outline),
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
                                      final bool due1 = userData.due;
                                      if (int.parse(currentweek1.text.trim()) >
                                          30) {
                                        const bool due1 = true;
                                      } else {
                                        const bool due1 = false;
                                      }
                                      final userData1 = Usermodel(
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
                                                  ProfileScreen()));
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
