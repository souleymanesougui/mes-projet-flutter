import 'package:flutter/material.dart';

void main() {
  runApp(const FamilyTreeApp());
}

class FamilyTreeApp extends StatelessWidget {
  const FamilyTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaïda Arami',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Segoe UI',
      ),
      home: const FamilyTreeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  final List<Map<String, dynamic>> _history = [];
  final TextEditingController _searchController = TextEditingController();
  final Map<String, dynamic> _family = {
    "name": "Arami Bollou",
    "children": [
      {
        "name": "Chelé",
        "children": [
          {"name": "Bohodo"},
          {"name": "Tchatchamaï"},
          {"name": "Djahaka"},
          {"name": "Badié"},
          {"name": "Kodogoï"},
          {"name": "Tchambé"},
          {"name": "Billah"},
          {"name": " Herdé"},
          {"name": "Harmallah"},
          {"name": "Tchekeï"}
        ]
      },
      {
        "name": "Togoï Derdibili",
        "children": [
          {
            "name": "Maïna",
            "children": [
              {"name": "Moursalli"},
              {"name": "Kebrin"},
              {"name": "Dedeï"},
              {"name": "Billah Maïnado"}
            ]
          },
          {
            "name": "Okor",
            "children": [
              {"name": "Souleymane"},
              {"name": "Inguilin"},
            ]
          },
        ]
      },
      {
        "name": "Abayoskoy",
        "children": [
          {"name": "Dadi"},
          {"name": "Okor"},
          {"name": "Chiné"},
          {"name": "Bazine"},
        ]
      },
      {
        "name": "Titir",
        "children": [
          {"name": "Sahanaï"},
          {"name": "Lodé"},
          {"name": "Barka"},
          {"name": "Togoï"},
          {"name": "Telebeï"},
        ]
      },
      {
        "name": "Hindjeï",
        "children": [
          {"name": "Boudi"},
        ]
      },
      {
        "name": "Karballah Bougoudi",
        "children": [
          {"name": "Bizallah"},
          {"name": "Halimé"},
          {"name": "Madigueï"},
          {"name": ".........."},
        ]
      },
      {
        "name": "Adama",
        "children": [
          {"name": "Woudaï"},
          {"name": "Dakin"},
          {"name": "Hawaï"},
          {"name": "Honi"},
          {"name": "Dagocheï"},
        ]
      },
      {
        "name": "Doya",
        "children": [
          {"name": "Doudou"},
          {"name": "Ali"},
          {"name": "Dedeï"},
          {"name": "Madigueï"},
          {"name": "Dohoné"},
        ]
      },
      {
        "name": "Kortegué",
        "children": [
          {"name": "Ereké"}
        ]
      },
      {
        "name": "Ziné",
        "children": [
          {"name": "Chelé2"},
          {"name": "Eï2"}
        ]
      },
      {
        "name": "Tikidé",
        "children": [
          {"name": "Chaha"},
          {"name": "Atcha"}
        ]
      },
      {
        "name": "Khineï",
        "children": [
          {"name": "Boudi"}
        ]
      },
      {
        "name": "Eï",
        "children": [
          {
            "name": "Kossoma",
            "children": [
              {"name": "Yosko"},
              {"name": "Ani"},
              {"name": "Baré"},
              {"name": "Sougoudou"}
            ]
          },
          {
            "name": "Gourdé",
            "children": [
              {"name": "Maïde"},
              {"name": "Herdé Gourdédo"},
              {"name": "Dakirdé Gourdédo"}
            ]
          },
          {
            "name": "Guissidé",
            "children": [
              {"name": "Issa"},
              {"name": "Hemichi"},
              {"name": "Woudaï"},
              {"name": "Hozo Guissidédo"}
            ]
          },
          {"name": "Dadouma"},
          {"name": "Honi"},
          {"name": "Onoromi"},
          {"name": "Handagala"},
          {"name": "Soukoura"},
          {"name": "Koudin"},
          {"name": "Yeskin"},
          {"name": "Atcha"},
          {"name": "Meram"}
        ]
      },
      {
        "name": "Naï",
        "children": [
          {
            "name": "Mahamat",
            "children": [
              {
                "name": "Adoum",
                "children": [
                  {"name": "Maïdé Adoum"},
                  {"name": "Abdallah"},
                  {"name": "Kelley"},
                  {"name": "Wardougou Adoum"},
                  {"name": "Abdraman"},
                  {"name": "Issa Adoum"},
                  {"name": "Tahar Adoum"},
                  {"name": "Idriss Adoum"},
                  {"name": "Daraya Adoumdo"},
                  {"name": "Howeï"},
                  {"name": "Herdé Adoumdo"},
                  {"name": "Galié Adoumdo"},
                  {"name": "Halimé Adoumdo"},
                  {"name": "Bakaya Adoumdo"},
                  {"name": "Maïmouna Adoumdo"},
                ]
              },
              {
                "name": "Lony Mahamat",
                "children": [
                  {"name": "Tougoudeï Lony"},
                  {"name": "Allafouza Lony"},
                  {"name": "Delleï Lony"},
                  {
                    "name": "Dicker Lony",
                    "children": [
                      {"name": "Mahamat Dicker"}
                    ]
                  },
                  {"name": "Fatimé Lonydo"},
                  {"name": "Dooubou Lonydo"},
                ]
              },
              {
                "name": "Cherfedine",
                "children": [
                  {"name": "Ali Cherfedine"},
                  {"name": "Brahim Cherfedine"},
                  {"name": "Oumar Cherfedine"},
                  {"name": "Hisseine Cherfedine"},
                  {"name": "Hamit Cherfedine"},
                  {"name": "Mahamat Cherfedine"},
                  {"name": "Hassan Cherfedine"},
                  {"name": "Herdé Cherfedinedo"},
                  {"name": "Kaltouma Cherfedinedo"},
                  {"name": "Fatimé Cherfedinedo"},
                ]
              },
              {
                "name": "Bechir",
                "children": [
                  {"name": "Oumar Bechir"},
                  {"name": "Brahim Bechir"},
                  {"name": "Zara Bechirdo"},
                  {"name": "Fatimé Bechirdo"},
                ]
              },
              {
                "name": "Adelkerim",
                "children": [
                  {"name": "Brahim Adelkerim"},
                  {"name": "Abdallah Adelkerim"},
                  {"name": "Hassani Adelkerim"},
                  {"name": "Djouma Adelkerim"},
                  {"name": "Aché Adelkerimdo"},
                  {"name": "Billah Adelkerimdo"},
                  {"name": "Halimé Adelkerimdo"},
                  {"name": "Houro Adelkerimdo"},
                  {"name": "Zara Adelkerimdo"},
                  {"name": "Achta Adelkerimdo"},
                  {"name": "Sadié Adelkerimdo"},
                  {"name": "Gachin Adelkerimdo"},
                  {"name": "Halimé2 Adelkerimdo"},
                ]
              },
              {
                "name": "Hozo",
                "children": [
                  {"name": "Mahamat Hozo Mahamatdo"},
                  {"name": "Meram Hozodo Mahamatdo"},
                  {"name": "Khadidja Hozodo Mahamatdo"},
                ]
              },
              {
                "name": "Fatimé",
                "children": [
                  {"name": "Djorou Modiin"},
                  {"name": "Wodji Modiin"},
                  {"name": "Sokaya Modiin"},
                  {"name": "Bokor Modiin"},
                  {"name": "Hodoya Modiin"},
                  {"name": "Tougoudeï Modiin"},
                  {"name": "Galié Modiindo"},
                  {"name": "Howoï Modiin"},
                ]
              },
              {
                "name": "Elié",
                "children": [
                  {"name": "Tahar Malimi"},
                  {"name": "Sokoya Malimi"},
                  {"name": "Hamid Malimi"},
                  {"name": "............"},
                  {"name": "Galin Malimido"},
                ]
              },
              {
                "name": "Chikan",
                "children": [
                  {"name": "Salah Bazana"},
                  {"name": "Kolouma Bazanado"},
                ]
              },
              {
                "name": "Makaï",
                "children": [
                  {"name": "Sougui"},
                  {"name": "Fatimé"},
                  {"name": "......."},
                ]
              },
              {"name": "Dakidé"}
            ]
          },
          {
            "name": "Allahi",
            "children": [
              {
                "name": "Hassan",
                "children": [
                  {"name": "Ali Hassan"},
                  {"name": "Goukouni Hassan"},
                  {"name": "Sounous Hassan"},
                  {"name": "Issa Hassan"},
                  {"name": "Kelley Hassan"},
                  {"name": "Merem Hassan"},
                  {"name": "Izé Hassan"},
                ]
              },
              {
                "name": "Choua",
                "children": [
                  {
                    "name": "Idriss Choua",
                    "children": [
                      {"name": "Moussa Idriss"},
                      {
                        "name": "Souleymane Idriss",
                        "children": [
                          {"name": "Idriss Souleymane Idriss"},
                        ]
                      },
                      {
                        "name": "Mahamat Idriss",
                        "children": [
                          {"name": "Amira Mahamat Idriss"},
                        ]
                      },
                      {"name": "Youssouf Idriss"},
                      {
                        "name": "Fatimé Idriss",
                        "children": [
                          {"name": "Seïf Adine"},
                          {"name": "Abdelaziz Mahamat"},
                          {"name": "Brahim Mahamat"},
                          {"name": "Abakar Mahamat"},
                          {"name": "Hawa Mahamat"},
                          {"name": "Khadidja Mahamat"},
                        ]
                      },
                      {
                        "name": "Kaltoum Idriss",
                        "children": [
                          {"name": "Idriss ..."},
                        ]
                      },
                      {"name": "Hallom Idriss"}
                    ]
                  },
                  {
                    "name": "Ahmat Choua",
                    "children": [
                      {"name": "Abakar Ahmat"},
                      {"name": "Ache Ahmat"},
                      {"name": "Amine Ahmat"},
                    ]
                  },
                  {
                    "name": "Abakar Choua",
                    "children": [
                      {
                        "name": "Mahamat Abakar Choua",
                        "children": [
                          {"name": "Abakar Mahamat Abakar"}
                        ]
                      },
                      {"name": "Djidi Abakar Choua"},
                      {"name": "Sokoto Abakar Choua"},
                      {"name": "Wassaï Abakar Choua"},
                      {"name": "Hassan Abakar Choua"},
                      {"name": "Choua Abakar Choua"},
                      {"name": "Guedé Abakar Choua"},
                      {"name": "Adoum Abakar Choua"},
                      {"name": "Youssouf Abakar Choua"},
                      {"name": "Idriss Abakar Choua"},
                      {
                        "name": "Galié Abakar Choua",
                        "children": [
                          {"name": "Abakar Oumar"},
                          {"name": "Mahamat Oumar"},
                          {"name": "Haroun Oumar"},
                          {"name": "Wassaï Oumar"},
                          {"name": "Nounou Oumar"},
                          {"name": "Sadié Oumar"},
                          {"name": "Naga Oumar"},
                        ]
                      },
                      {
                        "name": "Hazallah Abakar Choua",
                        "children": [
                          {"name": "Youssouf Hissen"},
                          {"name": "Mahamat Hissen"},
                          {"name": "Hedjeï Hissen"},
                          {"name": "Sadié Hissen"},
                        ]
                      },
                      {"name": "Amboua Abakar Choua"},
                      {"name": "Mariam Naga Abakar Choua"},
                      {"name": "Zanaba Abakar Choua"},
                      {
                        "name": "Khadidja Abakar Choua",
                        "children": [
                          {"name": "Abakar Oki"},
                          {"name": "Djanat Oki"},
                        ]
                      },
                      {"name": "Herdé Abakar Choua"},
                      {"name": "Fatimé Abakar Choua"},
                      {"name": "Nassirin Abakar Choua"},
                      {"name": "Hawa Abakar Choua"},
                      {"name": "Amira Abakar Choua"},
                      {"name": "Fatimé Abakar Choua"},
                      {"name": "Ache Abakar Choua"},
                      {"name": "Amné Abakar Choua"},
                      {"name": "Aché Abakar Choua"},
                      {"name": "Chedigué Abakar Choua"},
                      {"name": "Boudi Abakar Choua"},
                      {"name": "Tchanda Abakar Choua"},
                      {"name": "Niima Abakar Choua"},
                    ]
                  },
                  {
                    "name": "Abdallah Choua",
                    "children": [
                      {"name": "Mahamat Abdallah Choua"},
                      {"name": "Adoum Abdallah Choua"},
                      {"name": "Abakar Abdallah Choua"},
                      {"name": "Falmata Abdallah Choua"},
                      {"name": "Hawa Abdallah Choua"},
                      {"name": "Khadidja Abdallah Choua"},
                    ]
                  },
                  {
                    "name": "Youssouf Choua",
                    "children": [
                      {"name": "Hazallah Youssouf Choua"},
                      {"name": "Wassaï Youssouf Choua"},
                      {"name": "Sadier Youssouf Choua"},
                      {"name": "Zara Youssouf Choua"},
                      {"name": "Abakar Youssouf Choua"},
                      {"name": "Idriss Youssouf Choua"}
                    ]
                  },
                  {
                    "name": "Zanaba Chouado",
                    "children": [
                      {"name": "Abakar Adoum"},
                      {
                        "name": "Hissen Adoum",
                        "children": [
                          {"name": "Adoum Hissen"},
                          {"name": "Hassanié Hissen"},
                          {"name": "Fanné Hissen"},
                        ]
                      },
                      {"name": "Hamit Adoum"},
                      {"name": "Djido Adoum"},
                      {"name": "Hadidjeï Adoum"},
                      {"name": "Halimeï Adoum"},
                      {
                        "name": "Hassanié Adoum",
                        "children": [
                          {"name": "Zanaba Brahim"}
                        ]
                      },
                    ]
                  },
                  {
                    "name": "Hazallah Chouado",
                    "children": [
                      {"name": "Ali ..."},
                      {
                        "name": "Adoum Djimet",
                        "children": [
                          {"name": "Hazallah Adoum"},
                          {"name": "Mahbouba Adoum"},
                        ]
                      },
                      {
                        "name": "Idriss Béchir",
                        "children": [
                          {"name": "Dakou Idriss Béchir"}
                        ]
                      },
                      {
                        "name": "Boudi Djimet",
                        "children": [
                          {"name": "......"},
                          {"name": "Abakar Boloki"},
                          {"name": "Idriss Boloki"},
                          {"name": "Mahamat Boloki"},
                          {"name": "Batran Boloki"},
                          {"name": "Moussa Boloki"},
                          {
                            "name": "Hadje Boloki",
                            "children": [
                              {"name": "Andjaw"}
                            ]
                          },
                          {
                            "name": "Fatimé Zara Boloki",
                            "children": [
                              {"name": "Yacoub Goukouni"},
                              {"name": "Boloki Goukouni"}
                            ]
                          },
                          {
                            "name": "Khadidja Boloki",
                            "children": [
                              {"name": "Boloki ..."},
                              {"name": "Adoumou ..."},
                              {"name": "Hazallah ..."}
                            ]
                          },
                          {"name": "Habsa Boloki"},
                          {"name": "Ache Boloki"},
                          {"name": "Zara Boloki"},
                        ]
                      },
                      {
                        "name": "Khadidja Djimet",
                        "children": [
                          {"name": "Idriss Mahamat"},
                          {"name": "Ahmat Moussa"},
                          {"name": "Fanné Moussa"},
                          {"name": "Ache Moussa"},
                        ]
                      },
                      {
                        "name": "Ache Djimet",
                        "children": [
                          {"name": "Souleymane Sougui","photo": "Souleymane sougui.jpg"},
                          {"name": "Alhadje Sougui"},
                        ]
                      },
                      {"name": "......."},
                    ]
                  },
                  {
                    "name": "Hawa Chouado",
                    "children": [
                      {"name": "Bebeï Nébi"},
                      {"name": "Sadié Nébi"},
                      {"name": "Fanné Sougui"},
                    ]
                  },
                  {
                    "name": "Asta Chouado",
                    "children": [
                      {"name": "Awadji Mahamat"},
                      {"name": "Choua Mahamat"},
                      {"name": "Cherifier Mahamat"},
                      {"name": "Djallaba Mahamat"},
                      {"name": "Abakar Mahamat"},
                      {"name": "Abakar Mahamat"}
                    ]
                  },
                ]
              },
              {
                "name": "Dokom",
                "children": [
                  {"name": "Brahim Dokom"},
                  {
                    "name": "Wardougou Dokom",
                    "children": [
                      {"name": "Younous Wardougou"},
                      {"name": "Ahmat Wardougou"},
                      {"name": "Abakar Wardougou"},
                      {"name": "Ali Wardougou"},
                      {
                        "name": "Erem Wardougou",
                        "photo": "Errem.jpg"
                      },
                      {"name": "Adoum Wardougou"},
                      {"name": "Brahim wardougou"},
                      {"name": "Oumar wardougou"},
                      {"name": "Hamit Wardougou"},
                      {"name": "Togoï Wardougou"},
                      {"name": "Goukouni Wardougou"},
                      {"name": "Eli wardougou"},
                      {"name": "Dokom Wardougou"},
                      {"name": "Dowké Wardougoudo"},
                      {"name": "Achta Wardougoudo"},
                      {"name": "Mami Wardougoudo"},
                      {"name": "Fatimé Wardougoudo"},
                      {"name": "Khadidja Wardougoudo"},
                      {"name": "Dodow Wardougoudo"},
                      {"name": "Hatié Wardougoudo"},
                      {"name": "Mami2 Wardougoudo"},
                      {"name": "Zara Wardougoudo"},
                    ]
                  },
                  {"name": "Hamid Dokom"},
                  {"name": "Mahamat Dokom"},
                  {"name": "Allabahane Dokom"},
                  {"name": "Galié Dokomdo"},
                  {"name": "Djoria Dokomdo"},
                  {"name": "Kolouma Dokomdo"},
                  {"name": "Fatimé Dokomdo"},
                  {"name": "Dobougué Dokomdo"},
                ]
              },
              {
                "name": "Anar",
                "children": [
                  {"name": "Mahamat Anar"},
                  {"name": "Tahar Anar"},
                  {"name": "Hissein Anar"},
                  {"name": "Eheta Anardo"},
                  {"name": "Dakrin Anardo"},
                  {"name": "Heridjé Anardo"},
                  {"name": "Izé Anardo"},
                ]
              },
              {
                "name": "Goukouni",
                "children": [
                  {"name": "Djidi Goukouni"},
                  {"name": "Orozi Goukouni"},
                  {"name": "Togoï Goukouni"},
                  {"name": "Bouya Goukouni"},
                  {"name": "Moussa Goukouni"},
                  {"name": "Issaka Goukouni"},
                  {"name": "Yacoub Goukouni"},
                  {"name": "Daraya Goukounido"},
                  {"name": "Hotouma Goukounido"},
                  {"name": "Fatimé Goukounido"},
                  {"name": "Doya Goukounido"},
                ]
              },
              {
                "name": "Barkallah",
                "children": [
                  {"name": "Hodoya Barkallah"},
                  {"name": "Galié Barkallahdo"}
                ]
              },
              {"name": "Halliki"},
              {"name": "Issaka"},
              {
                "name": "Bidin",
                "children": [
                  {"name": "Bechir Miss"},
                  {"name": "Ali Miss"},
                  {"name": "Driya Miss"},
                  {"name": "Attaï Missdo"},
                  {"name": "Djokoti Missdo"},
                  {"name": "Daraya Missdo"},
                ]
              },
              {
                "name": "Mariam",
                "children": [
                  {"name": "Kouroumaï Hatcha"},
                  {"name": "Bokori Hatcha"},
                  {"name": "Maïdé Hatcha"},
                  {"name": "Koudié Hatchado"},
                  {"name": "Daraya Hatchado"},
                  {
                    "name": "Wozina Hatchado",
                    "children": [
                      {
                        "name": "Herendji Hassan",
                        "children": [
                          {"name": "Tahar Herendji"},
                          {"name": "Oumar Herendji"},
                          {"name": "Issaka Herendji"},
                          {"name": "Hamid Herendji"},
                          {"name": "Abdallah Herendji"},
                          {"name": "Issa Herendji"},
                          {"name": "Ahmat Herendji"},
                          {"name": "Mahamat Herendji"},
                          {"name": "Yissa Herendji"},
                          {"name": "Houké Herendji"},
                          {"name": "Dowchi Herendji"},
                          {"name": "Hourro Herendji"},
                          {"name": "Hawa Herendji"},
                          {"name": "Hadidja Herendji"},
                        ]
                      },
                      {"name": "Moussa Hassan"},
                      {"name": "Choua Hassan"},
                      {"name": "Ahmat Hassan"},
                      {"name": "Kortegué Hassan"},
                    ]
                  },
                  {"name": "Djonigué Hatchado"},
                  {"name": "Bazineï Hatchado"},
                  {"name": "Marazana Hatchado"},
                ]
              },
              {
                "name": "Kourtou",
                "children": [
                  {"name": "Guihini Tchigami"},
                  {"name": "Kondé Tchigami"},
                  {"name": "Bloki Tchigami"},
                  {"name": "Driya Tchigami"},
                  {"name": "Medi Tchigami"},
                  {"name": "Djazama Tchigamido"},
                  {"name": "Gachin Tchigamido"},
                  {"name": "Merem Tchigamido"}
                ]
              },
              {
                "name": "Harmallah",
                "children": [
                  {"name": "Brahim Tchitchaou"},
                  {"name": "Fatimé Tchitchaoudo"},
                  {"name": "Gourdjiya Tchitchaoudo"},
                  {"name": "Daoumaï Tchitchaoudo"},
                  {"name": "Heridjeï Tchitchaoudo"},
                  {"name": "Howoï Tchitchaoudo"}
                ]
              },
              {
                "name": "Dogocho",
                "children": [
                  {"name": "Ali"},
                ]
              },
              {
                "name": "Andjami",
                "children": [
                  {"name": "Brahim Erebi"},
                  {"name": "Adoum Erebi"},
                  {"name": "Fatimé Erebido"},
                  {"name": "Hawa Erebido"}
                ]
              },
              {
                "name": "Dochi",
                "children": [
                  {"name": "Sougui Touka"},
                  {"name": "Adoum Touka"},
                  {"name": "Brahim Touka"},
                  {"name": "......."}
                ]
              },
              {
                "name": "Karbillah",
                "children": [
                  {"name": "Wardougou Dahab"},
                  {"name": "Adoum Dahab"},
                  {"name": "Idriss Dahab"},
                  {"name": "Fatimé Dahabdo"},
                  {"name": "Izzé Dahabdo"},
                ]
              },
              {
                "name": "Daniyeï",
                "children": [
                  {"name": "Moussa ..."},
                  {"name": "Allabahane ..."},
                  {"name": "Orozi ..."},
                  {"name": "Attaï ..."},
                  {"name": "Wozina ..."},
                ]
              },
              {
                "name": "Hatié",
                "children": [
                  {"name": "Bereï ..."},
                ]
              },
              {"name": "Attaï Allahido"}
            ]
          },
          {
            "name": "Kerémi",
            "children": [
              {"name": "Koré Kerémi"},
            ]
          },
          {
            "name": "Azza",
            "children": [
              {"name": "Modigaï"},
              {"name": "Zara"},
              {"name": "Korin"},
              {"name": "Heleï"},
              {"name": "Wonimé"},
            ]
          },
          {
            "name": "Mihimi",
            "children": [
              {
                "name": "Allatchi mihimi",
                "children": [
                  {"name": "Salah Allatchi"},
                  {"name": "Abdallah Allatchi"},
                  {"name": "Kali Allatchi"},
                  {"name": "Mahamat Allatchi"},
                  {"name": "Morio Allatchido"},
                  {"name": "Khadidja Allatchido"},
                  {"name": "Houro Allatchido"},
                  {"name": "Medina Allatchido"}
                ]
              },
              {
                "name": "Hemichi Mihimi",
                "children": [
                  {"name": "Sougou Hemichi Mihimi"},
                  {"name": "Djorou Hemichi Mihimi"}
                ]
              },
              {
                "name": "Lony Mihimi",
                "children": [
                  {"name": "Harmallah Lony Mihimi"},
                ]
              },
              {"name": "Hidini"},
              {"name": "Gallah"},
              {"name": "Nockeï"}
            ]
          },
          {
            "name": "Mouhouma",
            "children": [
              {"name": "Sougou"},
              {"name": "Adoum"},
              {"name": "Koloï"},
              {"name": "Hassaballah"}
            ]
          },
          {
            "name": "Yosko",
            "children": [
              {"name": "Hadigne"},
              {"name": "Doma"},
              {"name": "Kabidé"},
              {"name": "Wodeï"}
            ]
          },
          {
            "name": "Guihini",
            "children": [
              {
                "name": "Haroun Guihini",
                "children": [
                  {"name": "Kelle Haroun"},
                  {"name": "Haroune Haroun"},
                  {"name": "Mallin Haroun"},
                  {"name": "Chedeï Haroun"},
                  {"name": "Houké Haroun"},
                  {"name": "Oldjou Haroun"},
                  {"name": "Herde Haroun"},
                  {"name": "Billah Haroun"}
                ]
              },
              {
                "name": "Dokom Guihini",
                "children": [
                  {"name": "Goukouni Dokom Guihini"},
                  {"name": "Zeni Dokom Guihini"},
                  {"name": "Koulin Dokom Guihini"},
                ]
              },
              {
                "name": "Orozi Guihini",
                "children": [
                  {"name": "Goukouni Orozi"},
                  {"name": "Tchaï Orozi"},
                  {"name": "Dadi Orozi"},
                  {"name": "Wardougou Orozi"},
                  {"name": "Billah Orozido"},
                  {"name": "Merem Orozido"},
                  {"name": "Khadidja Orozido"},
                  {"name": "Wozina Orozido"},
                  {"name": "Zara Orozido"}
                ]
              },
              {
                "name": "Hassan Guihini",
                "children": [
                  {"name": "Touka Hassan"},
                  {"name": "Djidi Hassan"},
                  {"name": "Togoï Hassan"},
                  {"name": "Tchou Hassan"},
                  {"name": "Hawa Hassando"},
                  {"name": "Attaboli Hassando"},
                  {"name": "Mourra Hassando"},
                  {"name": "Bildji Hassando"}
                ]
              },
              {
                "name": "Nokour Guihini",
                "children": [
                  {"name": "Goukouni Nokour"},
                ]
              },
              {
                "name": "Fatimé Guihinido",
                "children": [
                  {"name": "Ingaï Koroumaï"},
                  {"name": "Idriss Koroumaï"},
                  {"name": "Tinémi Koroumaïdo"},
                ]
              },
              {
                "name": "Zahara Guihinido",
                "children": [
                  {"name": "Djidi Nortogou"},
                  {"name": "Brahim Nortogou"},
                  {"name": "Tchou Kalia"},
                  {"name": "Biereï Nortogou"},
                  {"name": "Baïya Nortogou"},
                  {"name": "Daraya Nortogou"}
                ]
              },
              {
                "name": "Dowchi Guihinido",
                "children": [
                  {"name": "Bandi ..."},
                  {"name": "Barkaï ..."},
                  {"name": "Mariam ..."},
                ]
              }
            ]
          },
          {
            "name": "Deni",
            "children": [
              {"name": "Kebir"},
              {"name": "Toly"},
              {"name": "Ali"},
              {"name": "Hazallah Denido"},
              {"name": "Ziné Denido"},
              {"name": "Golié"},
              {"name": "Anirdé"}
            ]
          },
          {
            "name": "Boli Naïdo",
            "children": [
              {
                "name": "Adoum Boli Naïdo",
                "children": [
                  {"name": "Hassan Adoum"},
                  {"name": "Wozina Adoumdo"},
                  {"name": "Wodé Adoumdo"},
                  {"name": "Loukiyando Adoumdo"},
                ]
              },
            ]
          },
          {
            "name": "Djahini Naïdo",
            "children": [
              {"name": "Wolé Djahini Naïdo"},
              {"name": "Togo"},
              {"name": "Ehemedi"},
              {"name": "Chahallah"},
              {"name": "Dowin"},
            ]
          },
          {
            "name": "Boukou Naïdo",
            "children": [
              {
                "name": "Allangua",
                "children": [
                  {"name": "Hibi Allangua"},
                  {"name": "Wouddaï Allangua"},
                  {"name": "Chahallah Allangua"},
                ]
              },
              {
                "name": "Wardougou Naï",
                "children": [
                  {"name": "Allabahan Wardougou"},
                  {"name": "Hodoya Wardougou"},
                ]
              },
              {"name": "Ohi"}
            ]
          },
          {
            "name": "Hilé",
            "children": [
              {
                "name": "Djimé",
                "children": [
                  {"name": "Dadi ..."},
                  {"name": "Wardougou ..."},
                  {"name": "Abdallah ..."},
                  {"name": "Erebi ..."},
                  {"name": "Wodji ..."},
                  {"name": "Kourtïn ..."},
                  {"name": "Dowin ..."},
                  {"name": "Eliyeï ..."},
                ]
              },
              {"name": "Ali"},
              {"name": "Mina"}
            ]
          },
          {
            "name": "Djedidé",
            "children": [
              {"name": "Abdelkerim"},
            ]
          },
          {
            "name": "Delébo",
            "children": [
              {"name": "Chemi"},
              {"name": "Gallabou"}
            ]
          },
        ]
      }
    ]
  };

  Map<String, dynamic> _currentPerson = {};

  @override
  void initState() {
    super.initState();
    _currentPerson = _family;
  }

  void _displayPerson(Map<String, dynamic> person) {
    setState(() {
      _history.add(_currentPerson);
      _currentPerson = person;
    });
  }

  void _goBack() {
    if (_history.isNotEmpty) {
      setState(() {
        _currentPerson = _history.removeLast();
      });
    }
  }

  void _searchPerson(String query) {
    if (query.isEmpty) {
      _displayRoot();
      return;
    }

    // Trouver TOUS les chemins correspondants au lieu d'un seul
    final allPaths = _findAllPaths(_family, query.toLowerCase());

    if (allPaths.isNotEmpty) {
      setState(() {
        if (allPaths.length == 1) {
          // Un seul résultat : afficher normalement
          final path = allPaths[0];
          _history.clear();

          if (path.length > 1) {
            for (int i = 0; i < path.length - 2; i++) {
              _history.add(path[i]);
            }
            _currentPerson = path[path.length - 2];
          } else {
            _currentPerson = _family;
          }
        } else {
          // Plusieurs résultats : afficher une liste de choix
          _history.clear();
          _currentPerson = {
            "name": "Résultats de recherche pour '$query'",
            "children": allPaths.map((path) => path.last).toList(),
            "isSearchResults": true
          };
        }
      });
    }
  }

  List<Map<String, dynamic>>? _findPath(
      Map<String, dynamic> node, String target,
      [List<Map<String, dynamic>> path = const []]) {
    final currentPath = [...path, node];

    if (node["name"].toString().toLowerCase().contains(target)) {
      return currentPath;
    }

    if (node["children"] != null) {
      for (final child in node["children"]) {
        final result = _findPath(child, target, currentPath);
        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }

  List<List<Map<String, dynamic>>> _findAllPaths(
      Map<String, dynamic> node, String target,
      [List<Map<String, dynamic>> currentPath = const []]) {

    final paths = <List<Map<String, dynamic>>>[];
    final newPath = [...currentPath, node];

    // Vérifier si le nom correspond (correspondance partielle)
    if (node["name"].toString().toLowerCase().contains(target)) {
      paths.add(newPath);
    }

    // Rechercher récursivement dans les enfants
    if (node["children"] != null) {
      for (final child in node["children"]) {
        paths.addAll(_findAllPaths(child, target, newPath));
      }
    }

    return paths;
  }

  void _displayRoot() {
    setState(() {
      _history.clear();
      _currentPerson = _family;
    });
  }

  ImageProvider _loadImage(String path) {
    try {
      return AssetImage(path);
    } catch (e) {
      return const AssetImage('assets/images/ssi.jpg');
    }
  }

  String _getAncestryPath(Map<String, dynamic> person) {
    final path = _findPath(_family, person['name'].toString().toLowerCase());
    if (path != null && path.length > 1) {
      final ancestors = path.sublist(0, path.length - 1);
      return ancestors.map((a) => a['name']).join(' → ');
    }
    return 'Racine';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌳 Famille Gaïda Arami'),
        backgroundColor: const Color(0xFF273e47),
        elevation: 0,
        leading: _history.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _displayRoot,
            tooltip: 'Retour à la racine',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFCBF3F0), Color(0xFF2EC4B6), Color(0xFFfffae3)],
          ),
        ),
        child: Column(
          children: [
            // Search Box
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchPerson,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un nom...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.teal),
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),

            // Current location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _currentPerson['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF273e47),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tree View
            Expanded(
              child: _buildTreeView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeView() {
    // Vérifier si on affiche des résultats de recherche
    if (_currentPerson['isSearchResults'] == true) {
      return _buildSearchResultsView();
    }

    if (_currentPerson['children'] == null ||
        (_currentPerson['children'] as List).isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'La liste des enfants n\'est pas encore complète, elle est en cours d\'élaboration.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF273e47), fontSize: 18),
          ),
        ),
      );
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.8,
          ),
          itemCount: (_currentPerson['children'] as List).length,
          itemBuilder: (context, index) {
            final child = (_currentPerson['children'] as List)[index];
            final hasChildren = child['children'] != null && (child['children'] as List).isNotEmpty;

            return GestureDetector(
              onTap: () => _displayPerson(child),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: hasChildren ? const Color(0xFF2EC4B6) : const Color(0xFFCBF3F0),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: child['photo'] != null
                              ? _loadImage('assets/photos/${child['photo']}')
                              : const AssetImage('assets/images/ssi.jpg') as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          child['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF273e47),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasChildren)
                        const Padding(
                          padding: EdgeInsets.only(top: 5.0),
                          child: Text(
                            '(Enfants)',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchResultsView() {
    final results = _currentPerson['children'] as List;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentPerson['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF273e47),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.8,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final person = results[index];
                  final hasChildren = person['children'] != null && (person['children'] as List).isNotEmpty;

                  return GestureDetector(
                    onTap: () {
                      // Trouver le chemin complet pour cette personne
                      final path = _findPath(_family, person['name'].toString().toLowerCase());
                      if (path != null && path.isNotEmpty) {
                        setState(() {
                          _history.clear();
                          for (int i = 0; i < path.length - 1; i++) {
                            _history.add(path[i]);
                          }
                          _currentPerson = path.last;
                        });
                      }
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: hasChildren ? const Color(0xFF2EC4B6) : const Color(0xFFCBF3F0),
                              child: CircleAvatar(
                                radius: 36,
                                backgroundImage: person['photo'] != null
                                    ? _loadImage('assets/photos/${person['photo']}')
                                    : const AssetImage('assets/images/ssi.jpg') as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                person['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF273e47),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _getAncestryPath(person),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}