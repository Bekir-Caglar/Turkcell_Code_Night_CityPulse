import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:citypulse/core/theme/app_theme.dart';
import 'package:citypulse/core/network/api_service.dart';
import 'package:citypulse/widgets/custom_input_field.dart';
import 'package:citypulse/widgets/custom_dropdown_field.dart';
import 'package:gap/gap.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final bool isIOS = Platform.isIOS;

  String? _selectedCity;
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  final ApiService _apiService = ApiService();

  final List<String> _turkishCities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Aksaray',
    'Amasya',
    'Ankara',
    'Antalya',
    'Ardahan',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bartın',
    'Batman',
    'Bayburt',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Düzce',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Iğdır',
    'Isparta',
    'İstanbul',
    'İzmir',
    'Kahramanmaraş',
    'Karabük',
    'Karaman',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kilis',
    'Kırıkkale',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Mardin',
    'Mersin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Osmaniye',
    'Rize',
    'Sakarya',
    'Samsun',
    'Şanlıurfa',
    'Siirt',
    'Sinop',
    'Şırnak',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Uşak',
    'Van',
    'Yalova',
    'Yozgat',
    'Zonguldak',
  ];

  final Map<String, int> _turkishCitiesMap = {
    'Adana': 1,
    'Adıyaman': 2,
    'Afyonkarahisar': 3,
    'Ağrı': 4,
    'Amasya': 5,
    'Ankara': 6,
    'Antalya': 7,
    'Artvin': 8,
    'Aydın': 9,
    'Balıkesir': 10,
    'Bilecik': 11,
    'Bingöl': 12,
    'Bitlis': 13,
    'Bolu': 14,
    'Burdur': 15,
    'Bursa': 16,
    'Çanakkale': 17,
    'Çankırı': 18,
    'Çorum': 19,
    'Denizli': 20,
    'Diyarbakır': 21,
    'Edirne': 22,
    'Elazığ': 23,
    'Erzincan': 24,
    'Erzurum': 25,
    'Eskişehir': 26,
    'Gaziantep': 27,
    'Giresun': 28,
    'Gümüşhane': 29,
    'Hakkari': 30,
    'Hatay': 31,
    'Isparta': 32,
    'Mersin': 33,
    'İstanbul': 34,
    'İzmir': 35,
    'Kars': 36,
    'Kastamonu': 37,
    'Kayseri': 38,
    'Kırklareli': 39,
    'Kırşehir': 40,
    'Kocaeli': 41,
    'Konya': 42,
    'Kütahya': 43,
    'Malatya': 44,
    'Manisa': 45,
    'Kahramanmaraş': 46,
    'Mardin': 47,
    'Muğla': 48,
    'Muş': 49,
    'Nevşehir': 50,
    'Niğde': 51,
    'Ordu': 52,
    'Rize': 53,
    'Sakarya': 54,
    'Samsun': 55,
    'Siirt': 56,
    'Sinop': 57,
    'Sivas': 58,
    'Tekirdağ': 59,
    'Tokat': 60,
    'Trabzon': 61,
    'Tunceli': 62,
    'Şanlıurfa': 63,
    'Uşak': 64,
    'Van': 65,
    'Yozgat': 66,
    'Zonguldak': 67,
    'Aksaray': 68,
    'Bayburt': 69,
    'Karaman': 70,
    'Kırıkkale': 71,
    'Batman': 72,
    'Şırnak': 73,
    'Bartın': 74,
    'Ardahan': 75,
    'Iğdır': 76,
    'Yalova': 77,
    'Karabük': 78,
    'Kilis': 79,
    'Osmaniye': 80,
    'Düzce': 81,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şehir Verisi Ekle')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Şehir Bilgisi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Gap(16),

                CustomDropdownField<String>(
                  title: 'Şehir',
                  icon: Icons.location_city,
                  items: _turkishCities,
                  value: _selectedCity,
                  itemLabel: (city) => city,
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                  hintText: 'Şehir Seçin',
                ),

                const Gap(24),

                Text(
                  'Bilgiler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Gap(16),

                CustomInputField(
                  controller: _nameController,
                  label: 'İsim',
                  icon: Icons.person_outline,
                  // Validator ekle
                  // Eğer validator desteği eklenirse, buraya eklenebilir
                  hint: 'Adınızı girin',
                ),

                const Gap(16),

                CustomInputField(
                  controller: _messageController,
                  label: 'Mesaj',
                  icon: Icons.message_outlined,
                  hint: 'Mesajınızı girin',
                  maxLines: 4,
                ),

                const Gap(32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_selectedCity == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lütfen bir şehir seçin'),
                            ),
                          );
                          return;
                        }

                        try {
                          // Şehir adından plaka kodunu al
                          final cityId = _turkishCitiesMap[_selectedCity!]
                              ?.toString();
                          if (cityId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Geçersiz şehir seçimi'),
                              ),
                            );
                            return;
                          }

                          // Timestamp oluştur
                          final timestamp =
                              (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                                  .toString();

                          // API çağrısı
                          await _apiService.submitFeedback(
                            cityId: cityId,
                            userId: 'user_16',
                            message: _messageController.text.trim(),
                            timestamp: timestamp,
                          );

                          // Başarılı mesajı
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veri başarıyla gönderildi!'),
                            ),
                          );

                          // Formu temizle
                          _nameController.clear();
                          _messageController.clear();
                          setState(() {
                            _selectedCity = null;
                          });
                        } catch (e) {
                          print('Feedback submit error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Veri gönderilirken hata oluştu: $e',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 24),
                        Gap(12),
                        Text(
                          'Veriyi Gönder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Artık kullanılmayan eski dropdown metotları kaldırıldı
}
