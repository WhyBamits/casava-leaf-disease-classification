// ignore_for_file: equal_keys_in_map

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CassavaChatScreen extends StatefulWidget {
  const CassavaChatScreen({super.key});

  @override
  State<CassavaChatScreen> createState() => _CassavaChatScreenState();
}

class _CassavaChatScreenState extends State<CassavaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  late GenerativeModel _model;
  late ChatSession _chat;
  int _retryAttempts = 0;
  final int _maxRetries = 3;

  static const String _chatHistoryKey = 'chat_history';

  // Predefined Q&A database
  final Map<String, String> qaDatabase = {
    'common cassava diseases':
      'Common cassava diseases include:\n'
      '1. Cassava Mosaic Disease (CMD)\n'
      '2. Cassava Brown Streak Disease (CBSD)\n'
      '3. Cassava Bacterial Blight (CBB)\n'
      '4. Cassava Anthracnose Disease (CAD)',

  'identify mosaic disease':
      'Cassava Mosaic Disease symptoms:\n'
      '• Yellow or pale green patches on leaves\n'
      '• Distorted and twisted leaves\n'
      '• Stunted plant growth\n'
      '• Reduced root yield',

  'causes bacterial blight':
      'Cassava Bacterial Blight is caused by:\n'
      '• Bacteria: Xanthomonas axonopodis pv. manihotis\n'
      '• Spread through: Rain splash, contaminated tools\n'
      '• Favored by: High humidity and temperatures',

  // --- Disease Management (Expansion) ---
  'prevent cassava mosaic disease':
      'To prevent Cassava Mosaic Disease:\n'
      '• Use disease-free planting material\n'
      '• Rogue (remove) infected plants promptly\n'
      '• Control whitefly vectors\n'
      '• Plant resistant varieties',

  'symptoms of cassava brown streak disease':
      'Cassava Brown Streak Disease symptoms:\n'
      '• Yellowing along leaf veins (streaks)\n'
      '• Brown necrotic lesions on stems\n'
      '• Root constrictions and internal brown streaks\n'
      '• Hardening of roots, making them inedible',

  ' resistant cassava varieties for cmd':
      'Some cassava varieties resistant to Cassava Mosaic Disease (CMD) include:\n'
      '• TME 419\n'
      '• TMS 30572\n'
      '• Improved local landraces (check regional recommendations)',

  'manage cassava anthracnose disease':
      'Management of Cassava Anthracnose Disease (CAD) includes:\n'
      '• Using resistant varieties\n'
      '• Avoiding susceptible varieties\n'
      '• Maintaining good field hygiene\n'
      '• Pruning affected branches during dry periods to reduce inoculum',

  ' symptoms of cassava bacterial blight':
      'Symptoms of Cassava Bacterial Blight (CBB) include:\n'
      '• Angular water-soaked spots on leaves that turn brown\n'
      '• Wilting of leaves and shoots (blight)\n'
      '• Gummy exudates on stems and petioles\n'
      '• Dieback of stems and branches in severe cases',

  'cassava diseases be treated with chemicals':
      'While some chemical treatments exist for certain cassava diseases (e.g., specific fungicides for fungal diseases), for major viral diseases like CMD and CBSD, chemical control is largely ineffective. Emphasis is placed on resistant varieties, sanitation, and vector control.',

  'role of whiteflies in cassava diseases':
      'Whiteflies (Bemisia tabaci) are crucial vectors for transmitting Cassava Mosaic Disease (CMD) and Cassava Brown Streak Disease (CBSD) from infected plants to healthy ones. Controlling whitefly populations is a key strategy in preventing these viral diseases.',

  'how does cassava brown streak disease spread':
      'Cassava Brown Streak Disease (CBSD) spreads primarily through the movement of infected planting material (stem cuttings). It is also transmitted by whiteflies (Bemisia tabaci).',

  ' cassava green mite and how does it affect cassava':
      'Cassava Green Mite (Mononychellus tanajoa) is a tiny spider mite that feeds on cassava leaves, causing characteristic yellowing, distortion, and reduced leaf area, leading to stunted plant growth and significant yield losses, especially during dry seasons.',

  'identify viral diseases from nutrient deficiencies in cassava':
      'Distinguishing viral diseases from nutrient deficiencies in cassava can be tricky. Viral diseases (like CMD/CBSD) often show distinct mosaic patterns, vein clearing, and severe leaf distortion, sometimes localized to new growth. Nutrient deficiencies typically show more uniform discoloration patterns (e.g., general yellowing for nitrogen, purpling for phosphorus) across specific sets of leaves (older vs. younger).',

  // --- Cultivation & Agronomy (Expansion) ---
  'best time to plant cassava':
      'The best time to plant cassava is typically at the beginning of the rainy season, to ensure sufficient moisture for establishment. In many regions, this is between April and June.',

  'type of soil is best for cassava':
      'Cassava grows best in well-drained, fertile loamy soils with a pH between 5.5 and 7.0. It can tolerate poorer soils but yield will be reduced. Avoid waterlogged conditions.',

  'prepare land for cassava planting':
      'Land preparation for cassava involves:\n'
      '• Clearing vegetation\n'
      '• Ploughing and harrowing to create a fine tilth\n'
      '• Creating ridges or mounds, especially in areas prone to waterlogging',

  'ideal spacing for cassava plants':
      'Ideal spacing for cassava plants varies by variety and climate, but common recommendations are:\n'
      '• 1m x 1m (10,000 plants/hectare) for vigorous varieties\n'
      '• 0.8m x 0.8m (15,625 plants/hectare) for less vigorous varieties\n'
      '• Denser spacing can increase root numbers but reduce individual root size.',

  'fertilize cassava plants':
      'Fertilizer application for cassava depends on soil test results, but generally:\n'
      '• NPK fertilizers are recommended, especially high potassium (K)\n'
      '• Apply at planting or 4-6 weeks after emergence\n'
      '• Organic manure can also significantly improve soil fertility and yield',

  'when to harvest cassava':
      'Cassava is typically ready for harvest between 8 to 24 months after planting, depending on the variety and desired root size. Early-maturing varieties can be harvested sooner.',

  'select cassava planting material':
      'Select cassava planting material (stem cuttings) from healthy, mature, disease-free plants, ideally from the middle section of the stem, about 20-25 cm long with 5-7 nodes.',

  'benefits of intercropping cassava':
      'Benefits of intercropping cassava include:\n'
      '• Efficient use of land and resources\n'
      '• Increased overall farm productivity\n'
      '• Improved soil fertility (if legumes are intercropped)\n'
      '• Diversification of income and reduced risk\n'
      '• Weed suppression',

  'control weeds in cassava farms':
      'Weed control in cassava farms can be achieved through:\n'
      '• Manual weeding (hoeing)\n'
      '• Mechanical weeding\n'
      '• Use of herbicides (pre-emergent and post-emergent)\n'
      '• Mulching\n'
      '• Proper plant spacing to encourage canopy closure',

  ' the signs of nutrient deficiency in cassava':
      'Signs of nutrient deficiency in cassava vary:\n'
      '• Nitrogen (N): Uniform yellowing of older leaves, stunted growth\n'
      '• Phosphorus (P): Purplish discoloration of leaves, poor root development\n'
      '• Potassium (K): Yellowing/browning of leaf margins (scorching) on older leaves\n'
      '• Micronutrients: Interveinal chlorosis, distorted growth on younger leaves',

  'apply organic manure to cassava':
      'Organic manure (compost, farmyard manure) can be applied to cassava fields by:\n'
      '• Incorporating it into the soil during land preparation\n'
      '• Applying it in planting holes\n'
      '• Top-dressing around established plants',

  ' crop rotation in cassava cultivation':
      'Crop rotation in cassava cultivation involves growing cassava in sequence with other crops (e.g., legumes, cereals) on the same land. It helps to:\n'
      '• Break pest and disease cycles\n'
      '• Improve soil fertility and structure\n'
      '• Reduce weed pressure',

  'importance of pruning cassava':
      'Pruning cassava, especially during the vegetative stage, can promote branching and leaf production (for leafy vegetable varieties) or concentrate energy towards root development. It\'s also used to remove diseased parts of the plant.',

  'planting depth affect cassava establishment':
      'Proper planting depth (about two-thirds of the cutting length buried) is crucial for cassava establishment. Too shallow, and cuttings can dry out; too deep, and emergence might be delayed or inhibited, leading to poor rooting.',

  ' benefits of mulching in cassava cultivation':
      'Benefits of mulching in cassava cultivation include:\n'
      '• Weed suppression\n'
      '• Moisture retention in the soil\n'
      '• Temperature regulation (keeping soil cooler)\n'
      '• Gradual release of nutrients if organic mulch is used\n'
      '• Reduction of soil erosion',

  // --- Pest Management (Expansion) ---
  'common cassava pests':
      'Common cassava pests include:\n'
      '1. Cassava Green Mite (CGM)\n'
      '2. Whiteflies (vectors of CMD and CBSD)\n'
      '3. Mealybugs\n'
      '4. Termites\n'
      '5. Grasshoppers',

  'control cassava green mite':
      'Control methods for Cassava Green Mite (CGM) include:\n'
      '• Planting resistant varieties\n'
      '• Biological control (predatory mites)\n'
      '• Early planting to avoid peak dry season infestation\n'
      '• Use of acaricides as a last resort',

  'identify cassava mealybug infestation':
      'Cassava mealybug infestation is identified by:\n'
      '• White, cottony masses on stems, leaves, and growing tips\n'
      '• Stunted, distorted, and bunched leaves\n'
      '• Dieback of shoots\n'
      '• Presence of ants attracted to honeydew secreted by mealybugs',

  ' integrated pest management for cassava':
      'Integrated Pest Management (IPM) for cassava involves combining various control methods for pests, including:\n'
      '• Use of resistant varieties\n'
      '• Biological control (natural enemies)\n'
      '• Cultural practices (e.g., crop rotation, sanitation)\n'
      '• Judicious use of chemical pesticides when necessary, as a last resort',

  'biological controls for whiteflies in cassava':
      'Yes, natural enemies like parasitic wasps (e.g., Encarsia formosa, Eretmocerus mundus) can be used as biological controls for whiteflies in cassava, though their effectiveness can vary by region and environmental conditions.',

  'manage termite damage in cassava fields':
      'Managing termite damage in cassava fields involves:\n'
      '• Field sanitation (removing dead wood and stumps)\n'
      '• Crop rotation\n'
      '• Use of resistant varieties (if available)\n'
      '• Application of approved termiticides to mounds or planting holes in severe cases.',

  // --- Processing & Utilization (Expansion) ---
  'main uses of cassava':
      'The main uses of cassava include:\n'
      '• Food (fufu, gari, attieke, bread, chips)\n'
      '• Animal feed\n'
      '• Industrial starch\n'
      '• Bioethanol production',

  'process cassava into gari':
      'Processing cassava into gari involves:\n'
      '1. Peeling and washing roots\n'
      '2. Grating into a mash\n'
      '3. Fermenting and dewatering the mash\n'
      '4. Sifting and toasting (frying) the fermented mash',

  'nutritional value of cassava':
      'Cassava is primarily a source of carbohydrates. It also contains:\n'
      '• Some vitamins (e.g., Vitamin C, some B vitamins)\n'
      '• Minerals (e.g., calcium, phosphorus, iron)\n'
      '• It is low in protein and fats, so needs to be combined with other foods for a balanced diet.',

  ' cassava flour used for':
      'Cassava flour is a versatile gluten-free flour used for:\n'
      '• Baking (bread, cakes, cookies)\n'
      '• Thickening sauces and soups\n'
      '• Producing pasta and noodles\n'
      '• Making traditional dishes like fufu and ugali',

  'remove cyanide from cassava':
      'Cyanide is removed from cassava through various processing methods, including:\n'
      '• Peeling and grating\n'
      '• Soaking/fermenting (e.g., for gari, fufu)\n'
      '• Drying (sun-drying or artificial drying)\n'
      '• Cooking (boiling, frying)',

  'industrial cassava starch used for':
      'Industrial cassava starch is used in:\n'
      '• Adhesives and glues\n'
      '• Textiles (sizing)\n'
      '• Paper production\n'
      '• Pharmaceuticals\n'
      '• Food industry as a thickener, binder, and stabilizer',

  'bioethanol from cassava':
      'Bioethanol from cassava is an alternative fuel produced by fermenting the starch from cassava roots. It can be used as a standalone fuel or blended with gasoline.',

  'safety concerns with raw cassava':
      'Raw cassava contains cyanogenic glycosides, which can release toxic hydrogen cyanide when ingested. Proper processing is essential to remove these compounds and make cassava safe for consumption.',

  'difference between gari and fufu flour':
      'Gari is a granular, fermented, and toasted cassava product, often eaten by rehydrating or as a side dish. Fufu flour is typically unfermented, dried, and milled cassava, used to prepare the pounded fufu meal by cooking and stirring.',

  'cassava used in the brewing industry':
      'Cassava starch can be used as a fermentable sugar source in the brewing industry, either as a direct starch addition or converted to glucose syrup, contributing to the alcohol content in beer and other alcoholic beverages.',

  ' "attieke" and it made from cassava':
      'Attieke (also spelled Akyeke) is a popular fermented cassava staple from West Africa, particularly Cote d\'Ivoire. It\'s made by fermenting grated cassava, dewatering, sifting, and then steaming the granular product, similar to couscous.',

  // --- Varieties & Breeding (Expansion) ---
  ' some popular cassava varieties in africa':
      'Popular cassava varieties in Africa include:\n'
      '• TME 419\n'
      '• TMS 30572\n'
      '• Obasinjo (specific to Nigeria)\n'
      '• IITA improved varieties',

  'new cassava varieties developed':
      'New cassava varieties are developed through plant breeding programs, which involve:\n'
      '• Cross-pollination of parent plants with desired traits\n'
      '• Selection of offspring with superior characteristics (yield, disease resistance, quality)\n'
      '• Multi-locational trials to test performance',

  'difference between sweet and bitter cassava':
      'Sweet and bitter cassava varieties differ in their cyanogenic content. Sweet varieties have low cyanide levels and can often be consumed after simple cooking, while bitter varieties have high cyanide levels and require extensive processing (e.g., fermentation, prolonged drying) to be safe for consumption.',

  'biofortified cassava varieties':
      'Yes, biofortified cassava varieties have been developed, notably those enriched with Vitamin A (often identifiable by their yellow flesh) to combat Vitamin A deficiency, particularly in sub-Saharan Africa.',

  'participatory plant breeding in cassava':
      'Participatory plant breeding in cassava involves farmers actively in the selection and testing of new cassava varieties. This ensures that new varieties meet local preferences and conditions, increasing adoption rates.',

  // --- Economic Aspects (Expansion) ---
  'economic benefits of cassava cultivation':
      'Economic benefits of cassava cultivation include:\n'
      '• Food security for millions\n'
      '• Income generation for farmers\n'
      '• Raw material for various industries\n'
      '• Export potential for processed products',

  'cassava contribute to rural livelihoods':
      'Cassava contributes to rural livelihoods by:\n'
      '• Providing a staple food source for subsistence farmers\n'
      '• Offering income through sales of fresh roots or processed products\n'
      '• Creating employment opportunities in farming, processing, and marketing\n'
      '• Its resilience makes it a reliable crop in challenging conditions',

  'market opportunities for cassava in ghana':
      'In Ghana, market opportunities for cassava include:\n'
      '• Local consumption of fresh roots and traditional products (fufu, gari, agbeli kaklo)\n'
      '• Industrial demand for starch (textiles, paper, food processing)\n'
      '• Animal feed production\n'
      '• Emerging markets for high-quality cassava flour (HQCF) for bakery and industrial use\n'
      '• Bioethanol production (potential)',

  'typical yield of cassava per hectare':
      'The typical yield of cassava varies widely depending on variety, soil fertility, management practices, and climate. On average, yields can range from 10-25 tons per hectare, but with improved varieties and good agronomy, yields can reach 30-50+ tons per hectare.',

  'economic challenges of cassava production':
      'Economic challenges of cassava production include:\n'
      '• Low and fluctuating market prices for raw roots\n'
      '• High post-harvest losses due to perishability\n'
      '• Lack of access to stable markets and processing facilities\n'
      '• High labor costs for manual operations\n'
      '• Limited access to credit for farmers',

  'contract farming benefit cassava farmers':
      'Contract farming can benefit cassava farmers by providing:\n'
      '• Guaranteed market for their produce\n'
      '• Stable prices, reducing market risk\n'
      '• Access to inputs, credit, and technical advice from the contracting company\n'
      '• Encouragement for specialized production for industrial demand.',

  // --- Environmental Aspects (Expansion) ---
  'is cassava drought resistant':
      'Yes, cassava is known for its remarkable drought tolerance, making it a crucial crop in semi-arid regions. It can survive and produce a yield even under prolonged dry spells.',

  'oes cassava cultivation impact soil fertility':
      'Cassava is a heavy feeder of nutrients, particularly potassium. Continuous cassava cultivation without proper nutrient replenishment can deplete soil fertility. However, sustainable practices like crop rotation, intercropping with legumes, and organic matter addition can mitigate this.',

  'water requirements for cassava':
      'While drought-tolerant, cassava still requires adequate moisture, especially during establishment and early growth. Optimal water requirements are around 1000-1500 mm of well-distributed rainfall annually. Supplementary irrigation can boost yields in dry periods.',

  'cassava contribute to climate change mitigation':
      'Cassava can contribute to climate change mitigation by:\n'
      '• Its ability to grow on marginal lands, reducing pressure on forests\n'
      '• Its high biomass production, which can sequester carbon\n'
      '• Its potential for bioethanol production as a renewable energy source.',

  // --- General Information (Expansion) ---
  'cassava originate':
      'Cassava originated in South America, specifically in the Amazon basin. It was then introduced to Africa, Asia, and other parts of the world.',

  'global production of cassava':
      'Globally, cassava is one of the most important staple food crops, with annual production exceeding 280 million tons. Nigeria is the largest producer, followed by other African and Asian countries.',

  'local names for cassava in ghana':
      'In Ghana, cassava has several local names depending on the ethnic group, including:\n'
      '• Bankye (Akan/Twi)\n'
      '• Akplu (Ewe)\n'
      '• Etse (Ga)\n'
      '• Bayere (Ashanti)',

  'scientific name for cassava':
      'The scientific name for cassava is Manihot esculenta.',

  'How are you doing?':
      'Im fine today, how may i assist you today.',

  'cassava a root or a tuber':
      'Cassava is technically a root crop, specifically a storage root, not a tuber. Tubers (like potatoes) are swollen underground stems, while cassava roots are swollen adventitious roots.',

  // --- New Categories / Deeper Dives ---

  // Post-Harvest Management & Storage
  'store fresh cassava roots':
      'Fresh cassava roots have a very short shelf life (2-3 days after harvest). Storage methods include:\n'
      '• Leaving roots in the ground until needed (field storage)\n'
      '• Curing in moist sand or sawdust\n'
      '• Waxing or coating roots\n'
      '• Refrigeration (for short periods) or freezing (after processing)',

  'causes post-harvest deterioration in cassava':
      'Post-harvest deterioration in cassava is primarily caused by physiological deterioration (rapid desiccation and enzymatic browning) and microbial spoilage. Damage during harvest accelerates this.',

  'methods to extend cassava shelf life':
      'Methods to extend cassava shelf life include:\n'
      '• Immediate processing into stable products (flour, starch, gari)\n'
      '• Curing roots\n'
      '• Waxing or coating\n'
      '• Cold storage (refrigeration)\n'
      '• Freezing (after peeling and cutting)',

  // Health and Nutrition
  'cassava be eaten by diabetics':
      'Cassava is high in carbohydrates and has a high glycemic index, meaning it can cause a rapid rise in blood sugar. While it can be consumed by diabetics in moderation, portion control and combining it with protein and fiber are crucial. Processed forms like gari may have a slightly lower glycemic index than boiled cassava.',

  'cassava leaves edible':
      'Yes, cassava leaves are edible and are a good source of protein, vitamins (A, C), and minerals. They must be thoroughly cooked (boiled for extended periods, with multiple changes of water) to remove toxic cyanogenic compounds before consumption.',

  'health benefits of eating cassava':
      'The health benefits of eating cassava (when properly processed) include:\n'
      '• Energy source (carbohydrates)\n'
      '• Source of dietary fiber (aids digestion)\n'
      '• Contains some vitamins (C, B vitamins) and minerals (potassium, magnesium)\n'
      '• Gluten-free alternative for individuals with gluten sensitivity',

  'cyanide content of cassava':
      'The cyanide content in cassava varies significantly by variety and part of the plant, ranging from very low (sweet varieties, <50 ppm fresh weight) to very high (bitter varieties, >400 ppm). Leaves generally have higher cyanide than roots.',

  // Value Addition
  'high quality cassava flour hqcf':
      'High Quality Cassava Flour (HQCF) is a premium, unfermented cassava flour with low moisture content and good functional properties. It is often used as a substitute for wheat flour in baking (up to 20% blend) and in various industrial applications.',

  'cassava used in animal feed':
      'Cassava roots and leaves can be processed into animal feed. Roots are typically chipped, dried, and ground into a meal for livestock and poultry. Cassava leaves, after proper detoxification, provide protein.',

  'products derived from cassava starch':
      'Products derived from cassava starch include:\n'
      '• Glucose syrups (for sweeteners)\n'
      '• Dextrin (for adhesives)\n'
      '• Modified starches (for various food and industrial applications)\n'
      '• Bioethanol',

  'market potential for high quality cassava flour':
      'The market potential for High Quality Cassava Flour (HQCF) is significant, especially in countries aiming to reduce wheat flour imports. It serves as a cost-effective gluten-free alternative in the bakery industry and has applications in pharmaceuticals, textiles, and adhesives.',

  'cassava used in the pharmaceutical industry':
      'Cassava starch is used in the pharmaceutical industry as a binder, disintegrant, and filler in tablets and capsules. It is also used in the production of glucose and other derivatives for various medical applications.',

  // Challenges and Solutions
  'main challenges facing cassava farmers':
      'Main challenges facing cassava farmers include:\n'
      '• Diseases (CMD, CBSD)\n'
      '• Pests (CGM, whiteflies)\n'
      '• Low soil fertility\n'
      '• Lack of access to improved planting materials\n'
      '• Poor post-harvest handling and storage leading to losses\n'
      '• Limited access to markets and processing facilities\n'
      '• Climate change impacts (e.g., erratic rainfall)',

  'climate change affect cassava production':
      'Climate change can affect cassava production through:\n'
      '• Increased frequency and intensity of droughts (though cassava is tolerant, extreme drought affects yield)\n'
      '• Erratic rainfall patterns\n'
      '• Increased incidence and spread of pests and diseases due to changing temperatures\n'
      '• Changes in suitable growing areas',

  'role research play in cassava improvement':
      'Research plays a vital role in cassava improvement by:\n'
      '• Developing new high-yielding, disease-resistant, and climate-resilient varieties\n'
      '• Improving agronomic practices\n'
      '• Developing sustainable pest and disease management strategies\n'
      '• Enhancing processing technologies and value addition\n'
      '• Understanding the genetics and biochemistry of the crop',

  'best practices for sustainable cassava farming':
      'Best practices for sustainable cassava farming include:\n'
      '• Use of improved, disease-free planting material\n'
      '• Integrated Pest and Disease Management (IPDM)\n'
      '• Soil fertility management (crop rotation, organic matter, balanced fertilization)\n'
      '• Water efficient practices\n'
      '• Reducing post-harvest losses through proper handling and processing',

  'challenges of adopting improved cassava varieties':
      'Challenges of adopting improved cassava varieties include:\n'
      '• Limited availability and accessibility of planting material\n'
      '• Lack of awareness or knowledge among farmers\n'
      '• Perceived differences in taste or processing qualities compared to local varieties\n'
      '• High cost of certified planting material\n'
      '• Resistance to change among some farmers.',

  // Specific to Ghana (since current location is Sunyani, Ghana)
  ' government initiatives support cassava farmers in ghana':
      'Government initiatives supporting cassava farmers in Ghana may include:\n'
      '• Planting for Food and Jobs program (providing inputs, extension)\n'
      '• Promotion of improved varieties from CSIR-CRI (Council for Scientific and Industrial Research - Crops Research Institute)\n'
      '• Support for processing industries (e.g., starch, HQCF)\n'
      '• Farmer training and extension services',

  'where are major cassava processing hubs in ghana':
      'Major cassava processing hubs in Ghana are emerging in various regions, often near large farming communities. These include areas in the Ashanti, Bono, Eastern, and Volta regions, with a focus on gari, fufu flour, and increasingly HQCF and industrial starch.',

  'typical price of cassava in ghana':
      'The typical price of cassava in Ghana varies significantly based on season, region, supply, and demand. Prices are usually higher during the lean season and lower during peak harvest. Prices are often quoted per bag or per heap.',

  ' the common pests affecting cassava in ghana':
      'Common pests affecting cassava in Ghana are similar to the general list: Cassava Green Mite, Whiteflies, Mealybugs, and Termites. Regional variations in severity exist.',

  ' local dishes are made from cassava in ghana':
      'Popular local dishes made from cassava in Ghana include:\n'
      '• Fufu (pounded cassava and plantain/cocoyam)\n'
      '• Gari (fermented, toasted cassava granules)\n'
      '• Banku/Akple (fermented maize and cassava dough)\n'
      '• Akyeke/Attieke (fermented, steamed cassava granules, similar to couscous)\n'
      '• Abetee (boiled and pounded cassava)\n'
      '• Kokonte (dried cassava chips used to make a paste)',

  ' detoxification in cassava processing':
      'Detoxification in cassava processing refers to the methods used to reduce or eliminate the naturally occurring cyanogenic compounds (cyanide precursors) to safe levels for human or animal consumption.',

  'grow cassava in containers':
      'Growing cassava in containers is possible for small-scale or urban gardening. Use large containers (at least 15-20 gallons) with good drainage, well-draining potting mix, and ensure adequate sunlight, water, and nutrients.',
'Who created you?':
      'I am a final yaer project , designed by 2025 level 400 group 26 IT students. \n'
      'FOSU-HENE SYLVESTER (0597893855), \n '
      'WAHAB IBRAHIM (0599788509)\n',


  'role of microorganisms in cassava fermentation':
      'Microorganisms, primarily lactic acid bacteria and yeasts, play a crucial role in cassava fermentation. They break down carbohydrates, produce organic acids (which aid in detoxification and flavor development), and contribute to the characteristic taste and texture of products like gari and fufu.',

  'how does stem cutting age affect cassava yield':
      'The age of the stem cutting used for planting can affect cassava yield. Cuttings from mature (8-18 months old), healthy, lignified stems generally perform better than those from very young or very old stems, leading to better establishment and higher yields.',

  ' the benefits of proper cassava stem storage':
      'Proper storage of cassava stems (planting material) helps maintain their viability and reduces the risk of disease transmission. Stems should be stored vertically in a cool, dry place, away from direct sunlight, and protected from pests and diseases.',

  'test soil for cassava cultivation':
      'To test soil for cassava cultivation, take soil samples from various spots in the field and send them to an agricultural laboratory. The test results will provide information on soil pH, nutrient levels (N, P, K, micronutrients), and organic matter content, guiding fertilizer recommendations.',

  'purpose of ridging in cassava cultivation':
      'Ridging in cassava cultivation serves several purposes:\n'
      '• Improves drainage in waterlogged areas\n'
      '• Facilitates root development and tuberization\n'
      '• Makes weeding and harvesting easier\n'
      '• Helps warm the soil for better root growth',

  'manage soil erosion in cassava farms':
      'Managing soil erosion in cassava farms can be done through:\n'
      '• Contour planting on slopes\n'
      '• Terracing in hilly areas\n'
      '• Mulching with organic materials\n'
      '• Intercropping with cover crops\n'
      '• Maintaining good plant cover during early growth stages',

  ' the potential health risks of improperly processed cassava':
      'Improperly processed cassava can pose several health risks due to residual cyanogenic compounds, including:\n'
      '• Acute cyanide poisoning (leading to symptoms like vomiting, dizziness, weakness, and even death)\n'
      '• Chronic health problems like Konzo (a paralytic disease affecting the legs) and Tropical Ataxic Neuropathy (TAN), which cause nerve damage.',

  'cassava used in the textile industry':
      'Cassava starch is used in the textile industry for sizing yarns, which strengthens them and makes them smoother for weaving. It is also used in printing and finishing processes.',

  'shelf life of gari':
      'Gari has a relatively long shelf life, especially if properly dried and stored in airtight containers in a cool, dry place. It can last for several months to over a year without significant spoilage.',

  ' factors affect cassava root yield':
      'Factors affecting cassava root yield include:\n'
      '• Variety planted\n'
      '• Soil fertility and type\n'
      '• Climate (rainfall, temperature)\n'
      '• Planting material quality\n'
      '• Pest and disease incidence\n'
      '• Agronomic practices (spacing, weeding, fertilization)\n'
      '• Duration of growth before harvest',

  ' the latest innovations in cassava processing':
      'Latest innovations in cassava processing include:\n'
      '• Improved mechanical peelers and graters\n'
      '• Automated dewatering presses\n'
      '• Efficient flash dryers for HQCF production\n'
      '• Technologies for extracting value-added compounds (e.g., protein from leaves, industrial chemicals)\n'
      '• Development of mobile processing units',

  'how does cassava cultivation impact biodiversity':
      'Intensive monoculture of cassava can reduce local biodiversity. However, promoting intercropping, agroforestry systems with cassava, and using diverse varieties can help maintain and enhance biodiversity in cassava farming landscapes.',

  'role of extension services for cassava farmers':
      'Extension services play a crucial role in supporting cassava farmers by:\n'
      '• Disseminating improved technologies and practices\n'
      '• Providing training on agronomy, pest/disease management, and processing\n'
      '• Linking farmers to markets and credit facilities\n'
      '• Facilitating access to quality planting materials\n'
      '• Offering technical advice and troubleshooting',

  'can cassava be grown in saline soils':
      'Cassava has some tolerance to marginal soils, but it is generally sensitive to high salinity. Saline soils can inhibit growth and reduce yields significantly. It prefers well-drained, non-saline conditions.',

  'optimal temperature range for cassava growth':
      'The optimal temperature range for cassava growth is typically between 25°C and 30°C. Growth slows down significantly below 20°C and above 35°C.',

  'manage soil acidity for cassava':
      'To manage soil acidity for cassava, liming (applying agricultural lime) can be used to raise the pH to the optimal range (5.5-7.0). Organic matter addition also helps buffer soil pH.',

  'importance of early weeding in cassava':
      'Early weeding in cassava is crucial because young cassava plants are poor competitors with weeds. Early weed competition can significantly stunt growth and reduce final root yields. Weeding during the first 2-3 months is critical.',

  ' mechanical cassava harvesting':
      'Mechanical cassava harvesting involves the use of machines (e.g., tractor-mounted diggers, specialized harvesters) to lift roots from the soil. This can be more efficient for large-scale farms but requires specific soil conditions and is less common for smallholder farmers.',

  ' cassava processing waste used for':
      'Cassava processing waste (peels, fibrous residues) can be used for:\n'
      '• Animal feed (after appropriate treatment to reduce cyanide)\n'
      '• Biogas production\n'
      '• Compost/fertilizer\n'
      '• Growing mushrooms\n'
      '• Production of industrial enzymes',

  'how does fermentation affect cassava nutrients':
      'Fermentation can affect cassava nutrients in several ways:\n'
      '• Reduces cyanogenic glycosides, making it safe.\n'
      '• Can slightly reduce some vitamins (e.g., Vitamin C) but may increase others (e.g., some B vitamins due to microbial activity).\n'
      '• Improves digestibility of starches.',

  ' common post-harvest diseases of cassava':
      'Common post-harvest diseases of cassava are often associated with fungal or bacterial infections that cause rot, exacerbated by mechanical damage during harvest or poor storage conditions.',

  'role of cassava in global food security':
      'Cassava plays a critical role in global food security, particularly in sub-Saharan Africa, Asia, and Latin America, serving as a primary source of calories for hundreds of millions of people due to its resilience, high yield potential, and adaptability to marginal lands.',

  'how does cassava differ from yam':
      'Cassava and yam are both important root/tuber crops but differ in:\n'
      '• Botanical classification: Cassava is Manihot esculenta (Euphorbiaceae family); Yam is Dioscorea spp. (Dioscoreaceae family).\n'
      '• Growth habit: Cassava is a shrub; Yam is a climbing vine.\n'
      '• Cyanide content: Cassava contains cyanogenic glycosides requiring processing; Yam generally does not.\n'
      '• Texture/taste: Different culinary properties and traditional uses.',

  'history of cassava in africa':
      'Cassava was introduced to Africa from South America by Portuguese traders in the 16th century. It rapidly spread across the continent due to its adaptability, resilience, and high caloric yield, becoming a staple food for many populations.',

  ' cassava brown streak disease cbsd in detail':
      'Cassava Brown Streak Disease (CBSD) is a highly destructive viral disease caused by Ugandan Cassava Brown Streak Virus (UCBSV) and Cassava Brown Streak Virus (CBSV). It causes visible symptoms on leaves and stems but is most damaging due to severe root necrosis and hardening, making roots inedible. It is transmitted by whiteflies and infected planting material.',

  'manage soil compaction in cassava fields':
      'Managing soil compaction in cassava fields involves:\n'
      '• Minimizing heavy machinery traffic\n'
      '• Incorporating organic matter\n'
      '• Deep tillage or subsoiling before planting\n'
      '• Practicing no-till or minimum tillage where appropriate\n'
      '• Using cover crops to improve soil structure',

  ' the uses of cassava leaves in animal feed':
      'Cassava leaves, when properly processed (e.g., sun-dried or ensiled) to reduce cyanide, are a valuable protein source for animal feed, particularly for ruminants and poultry. They are rich in protein, vitamins, and minerals.',

  'how can value addition increase farmers income from cassava':
      'Value addition increases farmers\' income from cassava by transforming raw roots into higher-value processed products (e.g., gari, fufu flour, starch, HQCF). This extends shelf life, opens new markets, and allows farmers or processors to capture a larger share of the value chain.',

  'role of genetic diversity in cassava breeding':
      'Genetic diversity is fundamental in cassava breeding. It provides the raw material (different traits and genes) that breeders can select from and combine to develop new varieties with improved characteristics like higher yield, disease/pest resistance, drought tolerance, and better nutritional quality.',

  ' the benefits of community seed systems for cassava':
      'Community seed systems for cassava ensure local access to quality, disease-free planting material. Benefits include:\n'
      '• Decentralized production and distribution\n'
      '• Preservation of local landraces\n'
      '• Empowerment of local farmers to manage their own planting material supply\n'
      '• Reduced reliance on external sources',

  'how does integrated soil fertility management benefit cassava':
      'Integrated Soil Fertility Management (ISFM) benefits cassava by combining organic (manure, compost) and inorganic (chemical fertilizers) nutrient sources with improved cropping practices (e.g., intercropping, rotation) to sustainably enhance soil fertility and crop productivity.',

  ' the main challenges of scaling up cassava processing in africa':
      'Main challenges of scaling up cassava processing in Africa include:\n'
      '• Inconsistent supply of raw material (roots)\n'
      '• Lack of appropriate and affordable processing technologies\n'
      '• Limited access to finance for processors\n'
      '• Inadequate infrastructure (power, roads, water)\n'
      '• Quality control and standardization issues\n'
      '• Market access and competition',

  'identify nutrient deficiencies in cassava through visual symptoms':
      'Visual identification of nutrient deficiencies in cassava involves observing specific leaf discoloration patterns, growth abnormalities, and overall plant vigor. For example, general yellowing of older leaves might indicate nitrogen deficiency, while purpling could suggest phosphorus deficiency.',

  'potential of cassava as a climate-smart crop':
      'Cassava has high potential as a climate-smart crop due to its:\n'
      '• Drought tolerance and ability to grow in marginal soils\n'
      '• Flexibility in planting and harvesting times\n'
      '• Resilience to various stresses, making it a reliable food source in changing climates.\n'
      '• Potential for carbon sequestration in roots and biomass.',

  'how does starch extraction from cassava work':
      'Starch extraction from cassava involves:\n'
      '1. Washing and peeling roots\n'
      '2. Grating roots into a pulp\n'
      '3. Washing the pulp to release starch granules\n'
      '4. Sieving to separate starch from fiber\n'
      '5. Sedimentation or centrifugation to concentrate starch slurry\n'
      '6. Drying the starch (e.g., flash drying, sun drying) to a fine powder.',

  'role of the roots in cassava plant':
      'The primary role of the roots in a cassava plant is to store starch and water, making them the economically important part of the plant for human consumption and industrial use. They also anchor the plant and absorb water and nutrients from the soil.',

  'how does plant population affect cassava yield':
      'Plant population density significantly affects cassava yield. Too few plants result in low yield per area, while too many plants can lead to competition for resources, resulting in smaller roots and reduced overall yield. Optimal spacing is crucial for maximizing yield.',

  'common shelf life of fufu flour':
      'Fufu flour, when properly dried and stored in an airtight container in a cool, dry place, can have a shelf life of 6-12 months or even longer, making it a convenient form of processed cassava.',

  'how does cassava compare to other root crops in terms of yield':
      'Cassava generally has a high yield potential compared to other root crops like sweet potato or yam, especially on marginal lands and under challenging environmental conditions. Its ability to produce roots over an extended period also contributes to its high cumulative yield.',

  'importance of cassava for smallholder farmers':
      'Cassava is of immense importance to smallholder farmers because it:\n'
      '• Provides food security as a reliable staple crop\n'
      '• Requires relatively low input compared to other crops\n'
      '• Tolerates drought and poor soils\n'
      '• Offers flexibility in harvesting, acting as a "food bank" in the ground\n'
      '• Provides income generation opportunities through sales of roots or processed products.',

  ' the challenges of processing bitter cassava varieties':
      'Processing bitter cassava varieties poses challenges due to their high cyanide content, requiring more elaborate and time-consuming detoxification methods such as prolonged soaking, fermentation, and heating to ensure safety for consumption. This can be energy-intensive and require specific equipment.',

  'how does soil pH affect cassava growth':
      'Soil pH affects nutrient availability for cassava. Cassava prefers slightly acidic to neutral soils (pH 5.5-7.0). Outside this range, essential nutrients may become less available, leading to deficiencies and reduced growth and yield.',

  ' the benefits of using certified cassava planting material':
      'Using certified cassava planting material ensures that farmers receive healthy, disease-free cuttings of improved varieties. Benefits include:\n'
      '• Higher yields\n'
      '• Increased resistance to major diseases and pests\n'
      '• Consistent quality and growth\n'
      '• Reduced need for replanting and lower disease spread.',

  'role of cassava in poverty reduction':
      'Cassava contributes to poverty reduction by:\n'
      '• Providing a reliable food source for vulnerable populations.\n'
      '• Creating employment along its value chain (farming, processing, trade).\n'
      '• Offering income opportunities for smallholder farmers, especially women.\n'
      '• Being a resilient crop that can grow in marginal areas, providing food and income where other crops fail.',

  'how does cassava respond to different rainfall patterns':
      'Cassava is highly adaptable to various rainfall patterns. While it performs best with well-distributed rainfall, its deep root system allows it to tolerate dry spells and recover when rains return, making it resilient to erratic rainfall associated with climate change.',

  ' the key quality parameters for cassava starch':
      'Key quality parameters for cassava starch include:\n'
      '• Moisture content (low is better for storage)\n'
      '• Whiteness/purity\n'
      '• Viscosity (important for industrial applications)\n'
      '• Starch content (high is desirable)\n'
      '• Protein and ash content (lower is better for purity).',

  'role of international research centers in cassava':
      'International research centers like IITA (International Institute of Tropical Agriculture) and CIAT (International Center for Tropical Agriculture) play a crucial role in cassava by:\n'
      '• Developing improved varieties and advanced breeding techniques.\n'
      '• Conducting research on pest and disease management.\n'
      '• Improving post-harvest processing technologies.\n'
      '• Capacity building and knowledge transfer to national programs and farmers.',

  'cassava cultivation adapting to changing climates':
      'Cassava cultivation is adapting to changing climates through:\n'
      '• Breeding for increased drought and heat tolerance.\n'
      '• Developing varieties resistant to emerging pests and diseases.\n'
      '• Promoting climate-smart agricultural practices (e.g., water conservation, integrated soil fertility management).\n'
      '• Diversification of cassava production systems.',

  'potential for cassava in livestock feed in ghana':
      'The potential for cassava in livestock feed in Ghana is high. Processed cassava roots (chips, pellets, flour) can replace expensive imported maize as an energy source, while properly processed cassava leaves can serve as a protein supplement for poultry and ruminants, contributing to feed security and reducing import costs.',

  ' fermentation time for gari processing':
      'The fermentation time for gari processing typically ranges from 2 to 3 days (48-72 hours). This period allows beneficial microorganisms to break down cyanogenic glycosides and develop the characteristic flavor and aroma of gari.',

  'how does traditional cassava processing differ from modern methods':
      'Traditional cassava processing often relies on manual labor, sun-drying, and natural fermentation, leading to varied quality and lower efficiency. Modern methods incorporate mechanical peeling, grating, dewatering presses, and artificial dryers, resulting in higher throughput, improved hygiene, and more consistent product quality.',

  ' the main challenges for cassava farmers in Bono Region, Ghana':
      'Cassava farmers in Bono Region, Ghana, face challenges such as:\n'
      '• Prevalence of CMD and CBSD (though efforts are ongoing for resistant varieties).\n'
      '• Inconsistent rainfall patterns affecting rain-fed agriculture.\n'
      '• Limited access to quality certified planting materials.\n'
      '• Poor road infrastructure affecting transportation of roots to markets.\n'
      '• Fluctuating market prices and limited access to off-takers for industrial processing.',

  'how does cassava cultivation impact the environment positively':
      'Positive environmental impacts of cassava cultivation include:\n'
      '• Its ability to grow on degraded lands, helping with land rehabilitation.\n'
      '• Its deep root system can improve soil structure and prevent erosion on slopes.\n'
      '• Its use in biofuel production can reduce reliance on fossil fuels.\n'
      '• Can be integrated into agroforestry systems, contributing to carbon sequestration and biodiversity.',

  ' cassava processing residue used for in ghana':
      'In Ghana, cassava processing residue (peels, pomace from gari/starch production) is commonly used as animal feed, especially for pigs and small ruminants. It can also be composted for fertilizer or used for biogas production.',

  'how does early cassava harvesting affect root quality':
      'Early cassava harvesting (e.g., 6-8 months) typically yields smaller roots but with lower cyanide content and softer texture, making them suitable for fresh consumption or specific products. However, overall biomass and starch yield will be lower than at physiological maturity.',

  'role of mechanization in modern cassava farming':
      'Mechanization in modern cassava farming aims to increase efficiency and reduce labor costs. It involves:\n'
      '• Tractor-powered land preparation (ploughing, harrowing, ridging).\n'
      '• Mechanical planting for stem cuttings.\n'
      '• Mechanical weeders.\n'
      '• Mechanical harvesters (though still challenging for smallholders).',

  ' the requirements for exporting processed cassava products':
      'Exporting processed cassava products (e.g., HQCF, starch, gari) requires meeting international quality standards, including:\n'
      '• Strict moisture content limits.\n'
      '• Low levels of impurities and contaminants.\n'
      '• Adherence to phytosanitary regulations.\n'
      '• Proper packaging and labeling.\n'
      '• Compliance with importing country\'s food safety regulations.',

  'how can remote sensing help in cassava monitoring':
      'Remote sensing (using satellite imagery or drones) can help in cassava monitoring by:\n'
      '• Assessing plant health and vigor over large areas.\n'
      '• Detecting stress (e.g., drought, nutrient deficiency, disease outbreaks).\n'
      '• Estimating yield potential.\n'
      '• Mapping cassava cultivated areas for production statistics and planning.',

  ' cassava bread and it made':
      'Cassava bread, or cassava flatbread, is a traditional staple in parts of the Caribbean and South America. It\'s made by grating bitter cassava, pressing out the liquid (to remove cyanide), sifting the dry meal, and then baking it into thin, crisp flatbreads on a griddle or hot stone.',

  'how does cassava cultivation contribute to food security in ghana':
      'Cassava cultivation is fundamental to food security in Ghana as it is a primary staple food. Its resilience to harsh conditions ensures a consistent food supply, especially during lean seasons when other crops might fail. It provides readily available calories for a large part of the population.',

  ' the challenges in cassava genetic engineering':
      'Challenges in cassava genetic engineering include:\n'
      '• The complex genetic makeup of cassava (highly heterozygous, polyploid).\n'
      '• Difficulty in regeneration of whole plants from transformed cells.\n'
      '• Public acceptance and regulatory hurdles for GMO crops.\n'
      '• Delivering traits that are agronomically stable and beneficial to farmers.',

  'how can social media support cassava farmers':
      'Social media can support cassava farmers by:\n'
      '• Disseminating information on improved practices and market prices.\n'
      '• Connecting farmers with extension officers, researchers, and buyers.\n'
      '• Facilitating peer-to-peer learning and problem-solving.\n'
      '• Promoting processed cassava products to wider markets.',

  ' cyanide poisoning from cassava and its symptoms':
      'Cyanide poisoning from cassava occurs when improperly processed cassava is consumed, leading to the release of hydrogen cyanide. Symptoms can include vomiting, nausea, abdominal pain, headache, dizziness, weakness, and in severe cases, respiratory failure, convulsions, coma, and death.',

  'potential for cassava in ethanol production in ghana':
      'Ghana has significant potential for cassava-based ethanol production, driven by its large cassava production and the need for renewable energy sources. This could create new markets for farmers, reduce reliance on imported fossil fuels, and create rural employment, though infrastructure and investment are key challenges.',

  'how does cassava compare to maize as an animal feed ingredient':
      'Cassava is primarily an energy source (carbohydrate) for animal feed, similar to maize. However, cassava meal generally has lower protein than maize and needs protein supplementation. It\'s also gluten-free, which can be an advantage for some animal diets.',

  'role of starch in cassava roots':
      'Starch is the primary storage carbohydrate in cassava roots, making up about 20-40% of the fresh weight. It serves as the plant\'s energy reserve and is the main reason cassava is cultivated for food and industrial purposes.',

  ' the main types of cassava processing equipment for smallholders':
      'For smallholder cassava processors, common equipment includes:\n'
      '• Manual or small-scale motorized peelers.\n'
      '• Hand-operated or small motorized graters.\n'
      '• Manual screw presses for dewatering.\n'
      '• Simple drying mats or solar dryers.\n'
      '• Sifters and sieves.',

  'how does cassava cultivation affect soil nutrients':
      'Cassava is a nutrient-demanding crop, particularly for potassium. Continuous harvesting without replenishing nutrients can lead to depletion of soil potassium, nitrogen, and phosphorus over time, necessitating fertilizer application and sustainable soil management practices.',

  // --- Adding more general topics and deeper dives ---
  ' the major cassava producing countries globally':
      'The major cassava producing countries globally are Nigeria, Democratic Republic of Congo, Thailand, Indonesia, Brazil, and Angola. Nigeria is by far the largest producer worldwide.',

  'how does cassava grow from stem cuttings':
      'Cassava grows vegetatively from stem cuttings. When planted, dormant buds on the nodes of the cutting sprout to form shoots, and adventitious roots develop from the base of the cutting, which then swell to form storage roots.',

  ' the challenges of cassava breeding programs':
      'Challenges in cassava breeding programs include:\n'
      '• Long breeding cycle (takes many years to release a new variety).\n'
      '• Poor flowering and seed set in some desirable accessions.\n'
      '• High heterozygosity making genetic analysis and trait fixation difficult.\n'
      '• Susceptibility to diseases like CMD and CBSD that can wipe out promising lines.',

  'identify good quality cassava stem cuttings':
      'Good quality cassava stem cuttings should be:\n'
      '• From healthy, disease-free parent plants.\n'
      '• Mature (8-18 months old), woody stems.\n'
      '• Have 5-7 healthy nodes.\n'
      '• Free from pests, cracks, or damage.\n'
      '• Stored properly before planting to maintain viability.',

  'role of cassava in global food trade':
      'While most cassava is consumed locally in producing countries, it plays a role in global food trade primarily as processed products like starch, dried chips/pellets for animal feed, and to a lesser extent, high-quality cassava flour. Thailand is a major exporter of cassava products.',

  ' the environmental benefits of cassava production':
      'Environmental benefits of cassava production include its ability to grow on marginal and degraded lands, requiring fewer inputs than some other crops, and its role in carbon sequestration due to its significant biomass production. It also provides ground cover, reducing soil erosion.',

  'how can cassava contribute to industrial development':
      'Cassava can contribute to industrial development by providing a versatile raw material for various industries: food processing (starches, sweeteners), textile (sizing), paper, pharmaceuticals, and increasingly, bioethanol, creating jobs and fostering local economies.',

  'meaning of "cassava bank" in farming':
      'The term "cassava bank" refers to the practice of leaving mature cassava roots in the ground for extended periods (beyond typical harvest time). This acts as a living storage system, allowing farmers to harvest as needed, thus serving as a food security measure and reducing post-harvest losses.',

  'difference between cassava starch and cassava flour':
      'Cassava starch is the purified starch extracted from cassava roots, a white powder primarily used in industrial applications and as a thickener. Cassava flour, on the other hand, is made from dried and milled whole cassava roots (sometimes fermented), containing fiber and other components, and is mainly used for human consumption (e.g., baking, traditional dishes).',

  'how do you manage cassava pests without chemicals':
      'Managing cassava pests without chemicals can be achieved through: using resistant varieties, biological control (introducing or conserving natural enemies), cultural practices (e.g., good sanitation, crop rotation, timely planting/harvesting, intercropping), and manual removal of pests.',

  'role of cassava in animal feed in ghana':
      'In Ghana, cassava is a significant component of animal feed, especially for poultry and pigs. Roots are processed into chips or flour as an energy source, while properly processed leaves can provide protein. This helps reduce reliance on imported feed ingredients.',

  'economic importance of cassava in west africa':
      'Cassava is of immense economic importance in West Africa, serving as a primary staple food for over 200 million people. It provides income for millions of smallholder farmers, supports numerous processing industries (gari, fufu, starch), and plays a crucial role in regional food security and trade.',

  'how can new technologies improve cassava processing efficiency':
      'New technologies can improve cassava processing efficiency through:\n'
      '• Automation of labor-intensive tasks (peeling, grating).\n'
      '• Faster and more energy-efficient drying methods.\n'
      '• Improved extraction rates for starch or flour.\n'
      '• Enhanced quality control systems.\n'
      '• Development of versatile small-scale machines suitable for rural contexts.',

  'research focus of iita on cassava':
      'The International Institute of Tropical Agriculture (IITA) has a major research focus on cassava, including:\n'
      '• Breeding for high-yielding, disease-resistant (CMD, CBSD), and nutrient-rich (e.g., Vitamin A biofortified) varieties.\n'
      '• Developing sustainable pest and disease management strategies.\n'
      '• Improving agronomic practices and soil fertility management.\n'
      '• Researching post-harvest processing and value addition technologies.',

  'how does cassava cultivation affect greenhouse gas emissions':
      'The impact of cassava cultivation on greenhouse gas emissions varies. While land clearing for new farms can contribute to emissions, sustainable practices like no-till farming, cover cropping, and efficient fertilizer use can reduce emissions. Its potential for biofuel also contributes to reducing fossil fuel dependence.',

  ' the main challenges for cassava processing industries in ghana':
      'Main challenges for cassava processing industries in Ghana include:\n'
      '• Irregular supply and fluctuating price of raw cassava roots.\n'
      '• High energy costs for processing.\n'
      '• Inconsistent quality of raw materials.\n'
      '• Limited access to finance for expansion and modernization.\n'
      '• Competition from imported processed products.',

  ' konzo and it related to cassava':
      'Konzo is an irreversible paralytic disease affecting the legs, particularly prevalent in rural areas of Africa where populations rely heavily on bitter cassava as a staple food and have inadequate processing methods to remove cyanogenic compounds. It is caused by chronic exposure to high levels of cyanide from improperly processed cassava, especially when combined with a protein-deficient diet.',

  ' the health benefits of vitamin a biofortified cassava':
      'Vitamin A biofortified cassava, with its characteristic yellow-orange flesh, offers significant health benefits by providing dietary Vitamin A. This helps combat Vitamin A deficiency (VAD), which causes blindness and weakens the immune system, particularly in young children and pregnant women in regions where VAD is prevalent.',

  'how does market access affect cassava farmers income':
      'Market access significantly affects cassava farmers\' income. Good access to reliable markets (local, regional, or industrial) ensures that farmers can sell their produce at fair prices, reducing post-harvest losses and enabling them to invest in better farming practices, leading to higher profits.',

  'future outlook for cassava production':
      'The future outlook for cassava production is positive due to its resilience to climate change, its versatility as a food and industrial crop, and ongoing research efforts to improve yields and disease resistance. Demand for cassava and its processed products is expected to continue growing globally, especially in Africa.',

  'how does population growth impact cassava demand':
      'Population growth, particularly in sub-Saharan Africa, directly impacts cassava demand as it is a major staple food. As populations increase, so does the need for accessible and affordable food sources, making cassava even more critical for food security.',

  ' cassava stem rot':
      'Cassava stem rot refers to the decay of cassava stems, often caused by fungal or bacterial pathogens. It can occur in the field, on stored cuttings, or after planting, leading to poor establishment or dieback. Proper sanitation and use of healthy cuttings help prevent it.',

  'differentiate sweet and bitter cassava roots visually':
      'It is generally not possible to reliably differentiate sweet and bitter cassava roots visually based solely on their appearance (skin color, flesh color, size). The distinction lies in their cyanogenic content, which can only be determined through chemical testing or tasting after proper processing. It\'s crucial to know the variety you are planting or consuming.',

  ' the challenges in cassava mechanization for smallholders':
      'Challenges in cassava mechanization for smallholders include:\n'
      '• High cost of machinery.\n'
      '• Small and fragmented landholdings.\n'
      '• Lack of appropriate small-scale machinery tailored to diverse farming conditions.\n'
      '• Limited access to spare parts and maintenance services.\n'
      '• Lack of technical skills among farmers to operate and maintain machines.',

  'role of women in cassava value chain':
      'Women play a dominant and crucial role in the cassava value chain, particularly in cultivation (planting, weeding, harvesting) and almost exclusively in processing and marketing of traditional cassava products (gari, fufu flour). Empowering women in these areas is key to improving livelihoods and food security.',

  'how does cassava cultivation affect soil structure':
      'Cassava cultivation can affect soil structure. If managed poorly (e.g., intensive monoculture without organic matter, heavy tillage), it can degrade soil structure. However, with good practices like crop rotation, intercropping, and reduced tillage, cassava can contribute to improving soil structure due to its deep root system and biomass contribution.',

  ' the uses of cassava pulp after starch extraction':
      'After starch extraction, the remaining fibrous cassava pulp can be used as:\n'
      '• Animal feed (after detoxification)\n'
      '• Organic fertilizer/compost\n'
      '• Source of dietary fiber for human food products\n'
      '• Biogas production\n'
      '• Raw material for mushroom cultivation.',

  ' the major research institutions working on cassava in ghana':
      'In Ghana, the Council for Scientific and Industrial Research - Crops Research Institute (CSIR-CRI) is the primary national research institution working on cassava. They collaborate with international partners like IITA to develop and disseminate improved varieties and technologies.',

  'how can farmers access improved cassava planting material in ghana':
      'Farmers in Ghana can access improved cassava planting material through:\n'
      '• CSIR-CRI and its distribution networks.\n'
      '• Certified seed multipliers and private nurseries.\n'
      '• Government agricultural programs (e.g., Planting for Food and Jobs).\n'
      '• Farmer-to-farmer exchange of healthy cuttings from improved varieties.',

  'role of cassava in traditional medicine':
      'In some traditional medicine systems, parts of the cassava plant (leaves, roots, stem extracts) are used for various ailments, though scientific evidence for most uses is limited. For example, some traditions use cassava leaves for their purported anti-inflammatory or wound-healing properties.',

  'how can cassava be integrated into agroforestry systems':
      'Cassava can be integrated into agroforestry systems by planting it alongside trees or perennial crops. This provides shade, improves soil fertility through leaf litter, reduces erosion, diversifies farm income, and enhances biodiversity. Alley cropping with cassava is one example.',

  'process of making kokonte from cassava':
      'Making kokonte (or abakpa) from cassava involves:\n'
      '1. Peeling and slicing cassava roots into small chips.\n'
      '2. Sun-drying the chips until thoroughly dry.\n'
      '3. Milling the dried chips into a fine flour.\n'
      '4. The flour is then cooked with hot water into a thick paste, similar to fufu or banku.',

  ' cassava yield gap':
      'Cassava yield gap refers to the difference between the actual yield achieved by farmers and the potential yield that could be achieved under optimal conditions (e.g., with improved varieties, best management practices, and ideal environmental factors). Closing this gap is a major goal of agricultural research and development.',

  'how does intercropping with legumes benefit cassava':
      'Intercropping cassava with legumes (e.g., cowpea, groundnut) benefits cassava by:\n'
      '• Improving soil nitrogen through nitrogen fixation by the legumes.\n'
      '• Suppressing weeds.\n'
      '• Providing additional income from the legume crop.\n'
      '• Improving overall land productivity.',

  'impact of cassava processing on its nutritional value':
      'Cassava processing primarily impacts its nutritional value by reducing or eliminating cyanogenic compounds, making it safe. While some water-soluble vitamins (like Vitamin C) might be reduced during boiling or fermentation, overall carbohydrate content remains high. Fermentation can sometimes increase levels of B vitamins due to microbial activity.',

  ' the main types of cassava by cyanide content':
      'Cassava is broadly categorized into two main types based on cyanide content:\n'
      '1. Sweet Cassava: Low in cyanogenic glycosides (<50 ppm HCN equivalent fresh weight), generally safe to eat after simple cooking like boiling or frying.\n'
      '2. Bitter Cassava: High in cyanogenic glycosides (>50 ppm HCN equivalent fresh weight), requires extensive processing (e.g., prolonged soaking, fermentation, drying) to be safe for consumption.',

  'how does population density affect cassava cultivation practices':
      'In high population density areas, cassava cultivation tends to be more intensive, with smaller plots, higher reliance on intercropping, and greater emphasis on maximizing yield per unit area. In contrast, low population density areas might allow for more extensive farming and longer fallow periods.',

  'role of packaging in processed cassava products':
      'Packaging plays a critical role in processed cassava products by:\n'
      '• Protecting the product from moisture, contamination, and pests.\n'
      '• Extending shelf life.\n'
      '• Providing information to consumers (ingredients, nutritional value).\n'
      '• Enhancing market appeal and branding.\n'
      '• Ensuring food safety during transport and storage.',

  ' the advantages of cassava for food security':
      'The advantages of cassava for food security are numerous:\n'
      '• High caloric yield per unit area.\n'
      '• Drought tolerance and ability to grow in poor soils.\n'
      '• Flexible harvesting period ("food bank" in the ground).\n'
      '• Low input requirements compared to other staple crops.\n'
      '• Resilience to pests and diseases (for improved varieties).',

  'control post-harvest root rot in cassava':
      'Controlling post-harvest root rot in cassava involves:\n'
      '• Careful harvesting to minimize physical damage.\n'
      '• Rapid processing of roots after harvest.\n'
      '• Curing roots if short-term fresh storage is needed.\n'
      '• Proper sanitation of storage facilities.\n'
      '• In some cases, application of approved fungicides (though less common for fresh roots).',

  'potential for cassava flour in bakery products':
      'The potential for cassava flour (especially High Quality Cassava Flour - HQCF) in bakery products is significant. It can be blended with wheat flour (up to 20% or more depending on product) to produce bread, cakes, and pastries, reducing reliance on imported wheat and supporting local economies.',

  ' the key policy recommendations for cassava sector development':
      'Key policy recommendations for cassava sector development often include:\n'
      '• Investment in research and development for improved varieties and technologies.\n'
      '• Strengthening extension services and farmer training.\n'
      '• Developing efficient value chains and market linkages.\n'
      '• Providing access to finance and appropriate processing infrastructure.\n'
      '• Implementing favorable trade policies for cassava products.',

  // --- NEW ADDITIONS START HERE ---
  'hi':
      'Hello! How can I help you with information about cassava today?',

  'hello':
      'Hi there! I am ready to provide you with information about cassava.  would you like to know?',

  'i need your help':
      'I\'m here to help you with any questions you have about cassava. Please ask away!',

  ' do you do':
      'I am an AI assistant designed to provide comprehensive information about cassava, including its cultivation, diseases, pests, processing, nutritional value, economic aspects, and more.',

  'good morning, good afternon and good evening':
      'Good day! I hope you are having a productive time. How can I assist you with cassava-related questions?',

  'is cassava good for food':
      'Yes, cassava is a very important food crop, providing a staple source of carbohydrates for over half a billion people worldwide. It must be properly processed and cooked to remove naturally occurring toxic compounds and is best consumed as part of a balanced diet.',

  'uses of cassava':
      'Cassava has diverse uses, including:\n'
      '• Food: As a staple food (e.g., fufu, gari, attieke, bread, chips).\n'
      '• Animal Feed: Roots and processed leaves are used for livestock and poultry.\n'
      '• Industrial Starch: Used in textiles, paper, adhesives, pharmaceuticals, and food processing.\n'
      '• Bioethanol: Fermented starch is converted into biofuel.\n'
      '• Other: Leaves can be eaten as a vegetable (after proper cooking); stem cuttings are used as planting material.',
  // --- NEW ADDITIONS END HERE ---

  ' cassava?':
      'Cassava (Manihot esculenta) is a woody shrub of the Euphorbiaceae (spurge) family, extensively cultivated as an annual crop in tropical and subtropical regions for its edible starchy tuberous root, a major source of carbohydrates.',
  'how long does cassava take to grow?':
      'Cassava typically takes between 8 to 24 months to grow, depending on the variety, desired root size, and growing conditions. Early-maturing varieties can be harvested from 8 months, while late-maturing ones can take up to 24 months.',
  ' the main varieties of cassava?':
      'Main varieties of cassava include local landraces, and improved varieties developed through breeding programs. Some popular improved varieties in Africa are TME 419, TMS 30572, and various Vitamin A biofortified (yellow-fleshed) varieties. They are often classified as "sweet" or "bitter" based on their cyanide content.',
  'which cassava variety grows fastest?':
      'Generally, early-maturing cassava varieties grow fastest, producing harvestable roots within 8 to 12 months. Examples include some improved varieties specifically bred for quick maturity, though specific performance varies by region and conditions.',
  ' the nutritional values of cassava?':
      'Cassava is primarily a source of carbohydrates, providing high energy. It also contains some dietary fiber, Vitamin C, and small amounts of B vitamins and minerals like calcium, phosphorus, and iron. It is low in protein and fat, so it should be consumed with other food groups for a balanced diet.',
  ' cassava\'s uses besides food?':
      'Besides food, cassava is widely used for:\n'
      '• Animal Feed: Dried roots (chips/pellets) and processed leaves are excellent feed for livestock and poultry.\n'
      '• Industrial Starch: Used in textiles (sizing), paper production, adhesives, pharmaceuticals, and as a thickener in various industries.\n'
      '• Bioethanol: Its high starch content makes it a viable feedstock for bioethanol production.\n'
      '• Other: Leaves can be consumed as a vegetable (after proper processing), and stems are used as planting material for the next season.',
  'can cassava grow in poor soil?':
      'Yes, cassava is remarkably tolerant of poor soils, including those with low fertility and acidity, where many other crops would struggle. However, it performs best and yields higher in well-drained, fertile loamy soils. Improving soil fertility will always lead to better yields.',
  'how deep do cassava roots grow?':
      'Cassava roots, particularly the fibrous and non-storage roots, can grow quite deep, often reaching depths of 1-2 meters (3-6 feet) or more, especially in loose soils. The storage roots (the edible part) typically develop in the upper 30-60 cm (1-2 feet) of the soil.',
  'how many tonnes per hectare can i expect?':
      'Expected cassava yields vary significantly. For smallholder farmers using traditional methods, 10-25 tonnes per hectare is common. With improved varieties, good soil fertility, and proper management practices, yields can range from 30-50 tonnes per hectare, and even higher under optimal conditions.',
  'how do i identify good cassava planting materials?':
      'Good cassava planting materials (stem cuttings) should be:\n'
      '• From healthy, mature (8-18 months old), disease-free plants.\n'
      '• Obtained from the middle, woody part of the stem.\n'
      '• Approximately 20-25 cm (8-10 inches) long with 5-7 nodes.\n'
      '• Free from cracks, damage, or insect holes.\n'
      '• Plump and greenish-brown, not shriveled or dry.',

  // 2. Planting & Cultivation
  'best time to plant cassava?':
      'The best time to plant cassava is typically at the beginning of the rainy season. This ensures that the cuttings receive sufficient moisture for sprouting and initial growth, leading to better establishment and higher yields.',
  'how do i prepare land for cassava planting?':
      'Land preparation for cassava involves:\n'
      '• Clearing: Removing existing vegetation, stumps, and debris.\n'
      '• Ploughing & Harrowing: Tilling the soil to a fine tilth, which improves aeration and root penetration.\n'
      '• Ridging/Mounding: Creating ridges or mounds is often recommended, especially in areas prone to waterlogging, as it improves drainage and facilitates root development and harvesting.',
  '’s the recommended spacing for cassava?':
      'Recommended spacing for cassava varies based on variety, soil fertility, and intended use. Common spacing ranges from:\n'
      '• 1m x 1m (10,000 plants/hectare) for vigorous varieties.\n'
      '• 0.8m x 0.8m (15,625 plants/hectare) for less vigorous varieties or when aiming for higher root numbers.\n'
      '• Denser spacing (e.g., 0.75m x 0.75m) may be used for specific purposes like early harvest or leafy vegetable production.',
  'can cassava be grown with other crops?':
      'Yes, cassava is highly suitable for intercropping (growing with other crops simultaneously). Common companion crops include legumes (e.g., groundnuts, cowpea, beans), maize, and vegetables. Intercropping can improve soil fertility, suppress weeds, diversify income, and optimize land use.',
  ' ideal climatic conditions for cassava?':
      'Ideal climatic conditions for cassava include:\n'
      '• Temperature: Warm temperatures, optimally between 25°C and 30°C (77°F-86°F).\n'
      '• Rainfall: Well-distributed annual rainfall of 1000-1500 mm (40-60 inches), though it can tolerate lower amounts.\n'
      '• Sunlight: Full sunlight is preferred for optimal growth and root development.',
  'can cassava grow in dry regions?':
      'Yes, cassava is renowned for its remarkable drought tolerance and is often considered a "famine reserve" crop. It can survive and produce a yield even under prolonged dry spells where many other crops would fail, making it crucial for food security in arid and semi-arid regions.',
  'should i till the land before planting cassava?':
      'Tilling the land before planting cassava is generally recommended as it helps create a loose, aerated soil structure, which is conducive to root development and easier harvesting. However, in some conservation agriculture systems, minimum tillage or no-till methods with mulching can also be effective.',
  'can i use cassava cuttings more than once?':
      'No, you cannot use the same cassava cutting more than once for planting. Once a stem cutting has sprouted and grown into a plant, its function as a planting material is complete. New cuttings must be taken from healthy, mature stems of existing plants for subsequent plantings.',
  'how do i treat cassava stems before planting?':
      'Treating cassava stems before planting can improve establishment and reduce disease. Methods include:\n'
      '• Dipping in fungicide/insecticide: To protect against soil-borne diseases and early pest attacks (use approved chemicals and follow safety guidelines).\n'
      '• Soaking: Brief soaking in water can rehydrate cuttings, especially if they have been stored for some time.\n'
      '• Wound healing (Curing): Allowing cuttings to dry for a day or two in the shade to form a callus on the cut ends can reduce rot, though this is less common for routine planting.',
  'how can i improve soil fertility before planting?':
      'You can improve soil fertility before planting cassava by:\n'
      '• Adding Organic Matter: Incorporating compost, farmyard manure, or crop residues.\n'
      '• Crop Rotation: Rotating with legumes or other crops that improve soil health.\n'
      '• Liming: If the soil is too acidic, apply agricultural lime to raise the pH.\n'
      '• Green Manuring: Growing and incorporating a cover crop specifically to enrich the soil.\n'
      '• Balanced Fertilization: Applying basal fertilizers based on soil test recommendations.',

  // 3. Fertilizers & Nutrients
  'does cassava need fertilizer?':
      'While cassava can tolerate low-fertility soils, it is a nutrient-demanding crop, especially for potassium. Applying fertilizers, whether organic or inorganic, is highly recommended to achieve optimal yields and maintain long-term soil productivity.',
  'best fertilizer for cassava?':
      'The best fertilizer for cassava depends on your soil test results. However, cassava generally responds well to a balanced NPK (Nitrogen, Phosphorus, Potassium) fertilizer, with a particular need for Potassium (K). High-potassium fertilizers are often recommended.',
  'when should i apply fertilizer?':
      'For optimal results, fertilizer for cassava should typically be applied in two splits:\n'
      '• Basal Application: At planting or within 2-4 weeks after planting, to support initial growth.\n'
      '• Top-dressing: Around 3-4 months after planting, when the roots begin to tuberize and the plant has a high nutrient demand.',
  'is organic manure good for cassava?':
      'Yes, organic manure (like compost or farmyard manure) is excellent for cassava. It not only provides essential nutrients but also improves soil structure, water retention, and microbial activity, leading to healthier plants and sustained soil fertility.',
  'how often should i fertilize cassava?':
      'For best results, cassava is typically fertilized once or twice during its growth cycle, as described above (basal and top-dressing). Annual application is sufficient for a single cropping cycle.',
  'can i use compost for cassava?':
      'Absolutely! Compost is a highly beneficial amendment for cassava. It slowly releases nutrients, improves soil tilth, and enhances soil biology, contributing to vigorous growth and better yields. Incorporate it during land preparation or as a top-dressing.',
  'how do i test my soil before fertilizing?':
      'To test your soil before fertilizing:\n'
      '1. Collect Samples: Take several small samples from different spots across your field (avoiding unusual areas).\n'
      '2. Mix & Prepare: Mix these samples thoroughly to get a composite sample, then remove debris and air dry.\n'
      '3. Send to Lab: Send the sample to a reputable agricultural testing laboratory. They will analyze for pH, NPK, and micronutrient levels, providing recommendations for fertilizer application.',
  ' nutrients does cassava need most?':
      'Cassava needs Potassium (K) most, followed by Nitrogen (N) and Phosphorus (P). Potassium is crucial for root development and starch accumulation. It also requires micronutrients like zinc and boron, though in smaller quantities.',
  ' signs of nutrient deficiency in cassava?':
      'Signs of nutrient deficiency in cassava include:\n'
      '• Nitrogen (N): General yellowing of older leaves, stunted growth.\n'
      '• Phosphorus (P): Purplish discoloration of leaves (especially older ones), slow growth, poor root development.\n'
      '• Potassium (K): Yellowing and browning/scorching of leaf margins, particularly on older leaves, and reduced root size.\n'
      '• Micronutrients: Specific symptoms like interveinal chlorosis (yellowing between veins) on younger leaves for iron or zinc deficiency.',
  'can cassava grow without any fertilizer?':
      'Yes, cassava can grow without any added fertilizer, especially in relatively fertile soils or areas with long fallow periods. However, yields will likely be significantly lower than with proper nutrient management, and continuous cropping without fertilization will deplete soil nutrients over time.',

  // 4. Water & Irrigation
  'does cassava need irrigation?':
      'While cassava is known for its drought tolerance, it does benefit significantly from adequate moisture, especially during establishment and critical growth phases (first 3-4 months and during root bulking). Irrigation can boost yields, particularly in areas with erratic rainfall or prolonged dry seasons.',
  'how often should i water cassava?':
      'The frequency of watering depends on rainfall, soil type, and climate. During dry periods, especially in the first few months after planting, providing water once or twice a week (or as needed to keep the soil moist but not waterlogged) is beneficial. Established plants are more tolerant of dry spells.',
  'can cassava survive drought?':
      'Yes, cassava is highly resilient to drought. It can shed leaves to conserve moisture and re-sprout when rains return, allowing it to survive prolonged dry periods and still produce a reasonable yield, making it a vital food security crop in drought-prone areas.',
  'how do i irrigate cassava in dry seasons?':
      'To irrigate cassava in dry seasons, consider:\n'
      '• Drip Irrigation: Most efficient, delivering water directly to the plant roots, minimizing waste.\n'
      '• Furrow Irrigation: If feasible, running water down furrows between rows.\n'
      '• Manual Watering: For small plots, direct application with watering cans or hoses.\n'
      '• Mulching: Apply organic mulch around plants to conserve soil moisture and reduce evaporation.',
  'does overwatering affect cassava growth?':
      'Yes, overwatering or waterlogged conditions severely affect cassava growth. Cassava roots are highly susceptible to rot in saturated soils, leading to poor root development, nutrient uptake issues, and eventually plant death. Good drainage is crucial.',

  // 5. Pests & Diseases
  ' the common diseases in cassava?':
      'The common and most devastating diseases in cassava are:\n'
      '1. Cassava Mosaic Disease (CMD): Viral, transmitted by whiteflies and infected cuttings.\n'
      '2. Cassava Brown Streak Disease (CBSD): Viral, transmitted by whiteflies and infected cuttings, causes root necrosis.\n'
      '3. Cassava Bacterial Blight (CBB): Bacterial, causes angular leaf spots and blight.\n'
      '4. Cassava Anthracnose Disease (CAD): Fungal, causes cankers and dieback on stems.',
  'how do i prevent cassava mosaic disease?':
      'To prevent Cassava Mosaic Disease (CMD):\n'
      '• Use resistant varieties: Plant CMD-resistant cassava varieties.\n'
      '• Disease-free planting material: Use only healthy, certified virus-free stem cuttings.\n'
      '• Rogueing: Regularly remove and destroy infected plants immediately upon identification.\n'
      '• Whitefly control: Manage whitefly populations, as they are the primary vectors.',
  ' causes cassava brown streak?':
      'Cassava Brown Streak Disease (CBSD) is caused by two main viruses: Ugandan Cassava Brown Streak Virus (UCBSV) and Cassava Brown Streak Virus (CBSV). It is primarily spread through infected planting material (stem cuttings) and by whiteflies (Bemisia tabaci).',
  'how do i identify cassava blight?':
      'Cassava Bacterial Blight (CBB) is identified by:\n'
      '• Angular water-soaked spots: Appearing on leaves, often along veins, which later turn brown and necrotic.\n'
      '• Blight: Large, irregular necrotic areas on leaves, leading to wilting and defoliation.\n'
      '• Gummy exudates: Small, sticky, amber-colored drops of bacterial ooze on stems and petioles.\n'
      '• Dieback: In severe cases, stem and branch dieback can occur.',
  ' green mite in cassava?':
      'The Cassava Green Mite (Mononychellus tanajoa) is a tiny, spider-like pest that feeds on the underside of cassava leaves. Infestation causes characteristic yellowing, distortion, and puckering of leaves, especially on new growth, leading to reduced leaf area and significant yield losses, particularly during dry seasons.',
  ' cassava mealybugs?':
      'Cassava mealybugs (Phenacoccus manihoti) are small, soft-bodied insects covered in a white, waxy, cottony substance. They feed on plant sap, primarily on the growing tips, young leaves, and stems, causing severe stunting, leaf distortion, and a characteristic "bunchy top" appearance, and can lead to significant yield loss.',
  'how can i prevent cassava diseases organically?':
      'To prevent cassava diseases organically:\n'
      '• Use resistant varieties: Prioritize varieties known for natural resistance.\n'
      '• Strict sanitation: Use only healthy, disease-free planting material. Rogue and destroy infected plants promptly.\n'
      '• Crop rotation: Break disease cycles by rotating cassava with non-host crops.\n'
      '• Healthy soil: Maintain vigorous plant health through good soil fertility (e.g., compost, manure) to increase natural resilience.\n'
      '• Biological control: Encourage natural predators of whiteflies (vectors).',
  ' chemicals control cassava pests?':
      'Chemicals (pesticides/insecticides) can control some cassava pests, but their use is generally discouraged due to environmental and health concerns, and ineffectiveness against viral vectors. Examples include:\n'
      '• Acaricides: For severe green mite infestations.\n'
      '• Systemic insecticides: To control whiteflies or mealybugs, but often not economically viable or effective for viral transmission.\n'
      'Always use approved chemicals, follow label instructions carefully, and consider Integrated Pest Management (IPM) approaches.',
  ' biological control options for cassava?':
      'Biological control options for cassava include:\n'
      '• Natural Enemies: Introducing or conserving natural predators and parasitoids (e.g., parasitic wasps for mealybugs or whiteflies; predatory mites for green mites).\n'
      '• Biopesticides: Use of microbial agents (e.g., fungi that infect insects) where appropriate.\n'
      'The parasitic wasp *Anagyrus lopezi* was very successful in controlling the cassava mealybug in Africa.',
  'can pests reduce cassava yield?':
      'Yes, pests can significantly reduce cassava yield. Severe infestations by pests like cassava green mite or mealybugs can cause defoliation, stunted growth, and direct damage to roots, leading to substantial yield losses and reduced quality.',

  // 6. Disease Identification
  ' do cassava mosaic symptoms look like?':
      'Cassava Mosaic Disease (CMD) symptoms look like:\n'
      '• Mosaic patterns: Distinct yellow or pale green patches alternating with normal green areas on the leaves.\n'
      '• Leaf distortion: Leaves may appear crumpled, twisted, or misshapen.\n'
      '• Stunting: Severely infected plants are often stunted with reduced leaf size and overall vigor.\n'
      '• Reduced root yield: Infected plants produce small, woody, or no edible roots.',
  'how do i know if my cassava has brown streak?':
      'You can know if your cassava has brown streak disease (CBSD) by observing these symptoms:\n'
      '• Leaf symptoms: Yellowing or browning along the leaf veins, forming distinct streaks, often more pronounced on older leaves.\n'
      '• Stem symptoms: Dark brown, necrotic lesions on woody stems, sometimes causing dieback.\n'
      '• Root symptoms (most critical): Internal, dark brown, necrotic streaks or rot within the storage roots, making them unpalatable and woody. Roots may also be constricted.',
  ' root rot in cassava?':
      'Root rot in cassava refers to the decay and disintegration of the storage roots, typically caused by fungal or bacterial pathogens. It often occurs in waterlogged soils, soils with poor drainage, or if roots are damaged during harvest, leading to significant post-harvest losses or pre-harvest plant death.',
  'best way to inspect cassava for disease?':
      'The best way to inspect cassava for disease is to:\n'
      '• Regularly scout: Walk through your farm frequently, observing plants closely.\n'
      '• Check all parts: Inspect leaves (upper and lower surfaces), stems, and even roots (if suspecting CBSD or root rot).\n'
      '• Focus on new growth: Viral diseases like CMD often manifest clearly on newly emerging leaves.\n'
      '• Look for patterns: Note if symptoms are widespread, patchy, or localized, which can give clues about the disease.\n'
      '• Consult experts: If unsure, take clear photos or samples to an agricultural extension officer or plant pathologist.',
  'can i scan cassava leaves with an app?':
      'Yes, there are emerging mobile applications (apps) designed to help farmers diagnose cassava diseases by scanning leaves with their smartphone cameras. These apps often use artificial intelligence and image recognition to identify common diseases like Cassava Mosaic Disease and Cassava Brown Streak Disease, providing instant feedback and management advice.',

  // 7. Weed Management
  'how do i control weeds in cassava?':
      'Effective weed control in cassava can be achieved through a combination of methods:\n'
      '• Manual Weeding: Using hoes or hands, especially in the early stages.\n'
      '• Mechanical Weeding: Using cultivators or tractors between rows in larger fields.\n'
      '• Herbicides: Applying pre-emergent or post-emergent herbicides (ensure proper product selection and application).\n'
      '• Mulching: Applying organic materials (straw, crop residues) around plants to suppress weeds and conserve moisture.\n'
      '• Intercropping: Growing companion crops that suppress weeds.',
  'can i use herbicides in cassava fields?':
      'Yes, herbicides can be used in cassava fields to control weeds, especially in larger operations. However, it\'s crucial to:\n'
      '• Choose appropriate herbicides: Select products specifically registered for cassava and target your prevalent weed types.\n'
      '• Follow label instructions: Adhere strictly to recommended dosages, application timing, and safety precautions.\n'
      '• Consider environmental impact: Minimize drift and potential harm to non-target plants or water sources.',
  '’s the best manual method for weed control?':
      'The best manual method for weed control in cassava is hoeing. Regular and shallow hoeing, especially during the first 2-3 months after planting, is highly effective in controlling weeds before they compete significantly with the young cassava plants. Hand-pulling can be used for weeds very close to the plants.',
  'how often should i weed cassava farms?':
      'Weeding cassava farms is most critical during the first 2-4 months after planting, as young cassava plants are poor competitors with weeds. During this period, 2-3 weeding cycles may be necessary. After the canopy closes, the cassava plants themselves help suppress weeds, reducing the need for further weeding.',
  'can weeds affect cassava yield?':
      'Yes, weeds can significantly affect cassava yield. Uncontrolled weed growth, especially in the early stages, competes directly with cassava plants for water, nutrients, and sunlight, leading to stunted growth, reduced root development, and substantial yield losses.',

  // 8. Growth & Monitoring
  'how can i tell if my cassava is growing well?':
      'You can tell if your cassava is growing well by observing:\n'
      '• Vigorous growth: Healthy, upright stems and abundant, dark green leaves.\n'
      '• Good branching: Strong, well-developed branches.\n'
      '• Absence of symptoms: No signs of pests, diseases, or nutrient deficiencies.\n'
      '• Canopy closure: The leaves forming a dense canopy that shades the ground, indicating good growth and weed suppression.',
  'ideal height of a cassava plant?':
      'The ideal height of a cassava plant varies greatly by variety and growing conditions. Generally, healthy cassava plants can reach heights of 1.5 to 3 meters (5 to 10 feet) at maturity. Excessive height with sparse leaves might indicate stretching for light or poor root development.',
  'how long until cassava matures?':
      'Cassava typically reaches physiological maturity and is ready for harvest between 8 to 24 months after planting. Early-maturing varieties can be harvested from 8 months, while some traditional and late-maturing varieties may take up to 18-24 months for optimal root development.',
  ' growth stages does cassava go through?':
      'Cassava goes through several key growth stages:\n'
      '1. Establishment (0-2 months): Sprouting of cuttings, root initiation, and initial leaf development.\n'
      '2. Vegetative Growth (2-6 months): Rapid stem and leaf growth, branching.\n'
      '3. Root Bulking/Tuberization (6-12+ months): Accumulation of starch in the roots, leading to their swelling.\n'
      '4. Maturity (8-24 months): Roots reach desired size and starch content.',
  'when should cassava leaves be pruned?':
      'Cassava leaves are generally not pruned for root production, as leaves are essential for photosynthesis and root development. However, pruning may be done for:\n'
      '• Disease management: Removing infected leaves or branches.\n'
      '• Harvesting leaves: If the leaves are intended for consumption as a vegetable (though this can reduce root yield).\n'
      '• Promoting branching: In some systems, topping plants early can encourage branching for increased stem production.',

  // 9. Harvesting
  'when is cassava ready for harvest?':
      'Cassava is ready for harvest when the roots have reached a desirable size and starch content, typically between 8 to 24 months after planting. Signs include some yellowing of lower leaves and maturity specific to the variety. Unlike many crops, cassava can often be left in the ground for several months after maturity, serving as a "food bank."',
  'how do i harvest cassava without damage?':
      'To harvest cassava roots without damage:\n'
      '• Loosen soil: Carefully loosen the soil around the base of the plant using a hoe or digging stick.\n'
      '• Pull gently: Grasp the stem firmly near the base and pull upwards with a steady, strong motion. For larger plants, multiple people or leverage may be needed.\n'
      '• Avoid breaking roots: Try to minimize breaking the roots, as damage reduces their shelf life.\n'
      '• Mechanical harvesters: For large-scale farms, specialized mechanical harvesters can lift roots, reducing manual labor and damage.',
  'can i harvest cassava in parts?':
      'Yes, you can harvest cassava in parts, which is one of its unique advantages. This practice is known as "piecemeal harvesting" or "gradual harvesting." You can dig up individual mature roots while leaving others in the ground to continue growing or for later harvest, allowing for continuous supply and acting as a living storage system.',
  ' signs that cassava is overripe?':
      'While cassava can stay in the ground for an extended period, if left for too long (e.g., beyond 24-36 months for some varieties), it can become "overripe." Signs include:\n'
      '• Woodiness/Fibrousness: Roots become harder, more fibrous, and difficult to cook or process.\n'
      '• Reduced palatability: Taste may become less desirable.\n'
      '• Lower starch content: Starch may convert to fiber.',
  'how long can cassava stay in the ground?':
      'Cassava can typically stay in the ground for an extended period after maturity, often for 6-12 months, and sometimes even up to 24 months or more, depending on the variety and environmental conditions. This "field storage" acts as a valuable food reserve and is a key advantage of the crop.',

  // 10. Post-Harvest
  'how do i store cassava roots?':
      'Fresh cassava roots have a very short shelf life (1-3 days) after harvest. To store them:\n'
      '• Leave in ground (field storage): Most common and effective.\n'
      '• Curing: Store undamaged roots in moist sand, sawdust, or soil, in a cool, dark place to allow wounds to heal.\n'
      '• Waxing/Coating: Applying wax or paraffin can reduce moisture loss.\n'
      '• Refrigeration: For short periods, refrigeration can extend freshness.\n'
      '• Processing: The most effective long-term storage is processing into stable products like flour, gari, or chips.',
  'how long does cassava last after harvest?':
      'Fresh, unpeeled cassava roots typically last only 1 to 3 days after harvest at ambient temperatures before they start to deteriorate rapidly due to physiological deterioration (cyanide release, enzymatic browning) and microbial spoilage. Peeling and processing immediately is crucial for longer preservation.',
  'can cassava be preserved?':
      'Yes, cassava can be preserved effectively by processing it into stable forms. Common preservation methods include:\n'
      '• Drying: Sun-drying or mechanical drying to produce chips or flour.\n'
      '• Fermentation: For products like gari or fufu, which also detoxifies the roots.\n'
      '• Freezing: Peeled and cut cassava can be frozen for extended periods.\n'
      '• Waxing/Curing: For very short-term fresh root storage.',
  'how do i process cassava into flour?':
      'Processing cassava into flour (High Quality Cassava Flour - HQCF) typically involves:\n'
      '1. Peeling & Washing: Removing the outer skin and cleaning roots.\n'
      '2. Grating: Reducing roots to a fine mash.\n'
      '3. Pressing/Dewatering: Removing excess water from the mash.\n'
      '4. Sieving/Pulverizing: Breaking up the dewatered cake into fine granules.\n'
      '5. Drying: Sun-drying or using mechanical dryers to reduce moisture content to below 10-12%.\n'
      '6. Milling/Grinding: Grinding the dried chips/granules into a fine flour.\n'
      '7. Packaging: Storing in airtight bags.',
  'can cassava be dried for storage?':
      'Yes, drying is one of the most common and effective ways to store cassava for long periods. Roots are peeled, chipped, and then sun-dried or mechanically dried until their moisture content is low enough to prevent spoilage (typically below 10-12%). These dried chips can then be stored or milled into flour.',

  // 11. Processing & Value Addition
  ' products can i make from cassava?':
      'A wide range of products can be made from cassava, adding significant value:\n'
      '• Food Products: Gari, fufu, attieke, cassava flour (for baking), starch, tapioca, bread, chips, and various traditional dishes.\n'
      '• Animal Feed: Pellets, chips, and leaf meal.\n'
      '• Industrial Products: Industrial starch (for paper, textiles, adhesives, pharmaceuticals), glucose syrup, bioethanol, and composite materials.',
  'garri made from cassava?':
      'Making gari from cassava involves several steps:\n'
      '1. Peeling & Washing: Removing the skin and cleaning the roots.\n'
      '2. Grating: Reducing the roots into a mash.\n'
      '3. Fermentation & Dewatering: Placing the mash in sacks, allowing it to ferment naturally (for 2-3 days) while simultaneously pressing out water.\n'
      '4. Sieving: Separating the fermented mash into fine granules.\n'
      '5. Toasting/Frying: Frying the granules in a hot pan (traditionally an iron pan) to cook and dry them into the final granular gari product.\n'
      '6. Cooling & Packaging: Allowing gari to cool before packaging.',
  ' fufu and it made?':
      'Fufu is a staple food in many parts of West and Central Africa, made by pounding starchy foods into a soft, dough-like consistency. When made from cassava, it typically involves:\n'
      '1. Boiling/Steaming: Peeled cassava roots are boiled or steamed until very soft.\n'
      '2. Pounding: The cooked cassava is then pounded in a mortar with a pestle until a smooth, cohesive dough is formed. (Alternatively, "fufu flour" is made from dried cassava which is then reconstituted and stirred in hot water to achieve a similar consistency).',
  'can cassava be used for animal feed?':
      'Yes, cassava is widely used for animal feed, especially for pigs, poultry, and ruminants. The roots are chipped, dried (pellets or meal) as an energy source, replacing maize in diets. Cassava leaves, after proper processing (e.g., wilting, sun-drying) to reduce cyanide, are a good source of protein and vitamins for livestock.',
  'can i produce ethanol from cassava?':
      'Yes, you can produce ethanol from cassava. Cassava\'s high starch content makes it an excellent feedstock for bioethanol production. The process involves converting the starch into fermentable sugars, which are then fermented by yeast to produce ethanol, followed by distillation and dehydration.',

  // 12. Marketing & Sales
  'where can i sell cassava?':
      'You can sell cassava in various markets:\n'
      '• Local Markets: Directly to consumers or local vendors.\n'
      '• Wholesale Markets: To larger traders who distribute to urban centers.\n'
      '• Processors: To factories that produce gari, fufu flour, starch, or animal feed.\n'
      '• Restaurants/Hotels: Supplying fresh roots or specific processed products.\n'
      '• Export Markets: For processed products like starch or HQCF, depending on quality and demand.',
  'current market price of cassava?':
      'The current market price of cassava varies significantly by region, season, variety, and whether it\'s fresh or processed. Prices are usually higher during the lean season (when supply is low) and lower during the peak harvest season. It\'s best to check with local market authorities or agricultural extension services for the most up-to-date prices in your specific area (e.g., Sunyani, Bono Region).',
  'how can i export cassava?':
      'Exporting cassava, especially processed products like High Quality Cassava Flour (HQCF) or starch, involves:\n'
      '1. Meeting Quality Standards: Ensuring products meet international food safety and quality regulations.\n'
      '2. Market Research: Identifying target markets and their specific import requirements.\n'
      '3. Logistics: Arranging for transport, customs clearance, and cold chain (if applicable).\n'
      '4. Documentation: Obtaining necessary export permits, certificates of origin, and phytosanitary certificates.\n'
      '5. Networking: Connecting with international buyers or export agents.',
  ' companies buy cassava in bulk?':
      'Companies that buy cassava in bulk typically include:\n'
      '• Industrial Starch Manufacturers: For use in food, textile, paper, and pharmaceutical industries.\n'
      '• Ethanol Producers: For biofuel production.\n'
      '• Large-scale Food Processors: Producing gari, fufu flour, or other cassava-based food products for wider distribution.\n'
      '• Animal Feed Manufacturers: For inclusion in livestock and poultry feed.\n'
      'Specific companies would vary by region (e.g., Ghana, Nigeria).',
  'can i sell cassava online?':
      'Selling fresh cassava roots directly online is challenging due to their short shelf life and bulkiness. However, you can effectively sell processed cassava products (like gari, fufu flour, or HQCF) online through e-commerce platforms, social media, or dedicated agricultural marketplaces, reaching a wider customer base beyond local markets.',

  // 13. Climate & Environment
  'can cassava grow in salty soil?':
      'While cassava is tolerant of many marginal soil conditions, it is generally sensitive to high salinity. Salty soils can inhibit growth and reduce yields significantly. It prefers well-drained, non-saline conditions. Extreme salinity will negatively impact its performance.',
  'does cassava need full sunlight?':
      'Yes, cassava needs full sunlight for optimal growth and root development. It is a sun-loving crop and requires at least 6-8 hours of direct sunlight daily. Shading can lead to leggy growth, reduced leaf area, and significantly lower root yields.',
  'how does climate change affect cassava?':
      'Climate change can affect cassava, though it is one of the most resilient crops. Impacts include:\n'
      '• Erratic Rainfall: More frequent droughts or intense rainfall affecting yields.\n'
      '• Temperature Changes: Altering optimal growing zones and potentially increasing pest/disease pressure.\n'
      '• Increased Pests/Diseases: Warmer temperatures can favor the spread and severity of certain pests (e.g., whiteflies) and diseases (e.g., CBSD). However, its inherent resilience also makes it a "climate-smart" crop for adaptation strategies.',
  'can cassava tolerate flooding?':
      'No, cassava has very poor tolerance to flooding or waterlogged conditions. Its roots are highly susceptible to rot in saturated soils, leading to plant death and significant yield losses. Good drainage is essential for successful cassava cultivation.',
  'can i plant cassava near rivers?':
      'You can plant cassava near rivers, but with caution. Ensure the area has excellent drainage and is not prone to flooding or prolonged waterlogging. Riverbanks often have fertile soil, but proximity to water bodies increases the risk of waterlogging, which is detrimental to cassava. Also, consider any riparian buffer zone regulations.',

  // 14. Rotation & Companion Crops
  'can i rotate cassava with maize?':
      'Yes, rotating cassava with maize is a common and beneficial practice. Maize is a cereal crop that complements cassava well in a rotation system. It helps break pest and disease cycles specific to cassava, and can improve overall soil health and nutrient balance. Ensure proper fertilization for both crops.',
  ' good companion crops for cassava?':
      'Good companion crops for cassava often include:\n'
      '• Legumes: Cowpea, groundnuts (peanuts), beans, and soybeans. They fix nitrogen, improving soil fertility for cassava.\n'
      '• Cereals: Maize (corn) and sorghum, for diversified income and breaking pest cycles.\n'
      '• Vegetables: Some leafy greens or short-duration vegetables can be grown in the early stages before the cassava canopy closes.',
  'can cassava deplete soil nutrients?':
      'Yes, cassava can deplete soil nutrients, especially potassium, if grown continuously without nutrient replenishment. It is a heavy feeder, extracting significant amounts of nutrients from the soil. Long-term sustainable cultivation requires proper fertilization, crop rotation, and incorporation of organic matter to maintain soil fertility.',
  'how long should i wait before planting cassava again?':
      'If you\'re practicing crop rotation, it\'s generally recommended to wait at least 1-2 years before planting cassava again in the same plot after a cassava harvest. This allows for the break in pest and disease cycles and provides an opportunity to replenish soil nutrients with different crops.',
  'can i intercrop cassava and yam?':
      'Intercropping cassava and yam is sometimes practiced, but it can be challenging due to their differing growth habits and nutrient demands. Yam is a climbing vine, requiring support, while cassava is an upright shrub. Competition for light and nutrients can occur. Careful management of spacing and nutrient supply is crucial if attempted.',

  // 15. Training & Learning
  'are there training programs for cassava farmers?':
      'Yes, there are numerous training programs for cassava farmers, often offered by:\n'
      '• Government Agricultural Extension Services: At district or regional levels.\n'
      '• Agricultural Research Institutes: Like CSIR-CRI in Ghana or IITA.\n'
      '• NGOs and Development Organizations: Focused on rural development and food security.\n'
      '• Farmer Cooperatives: Often organize peer-to-peer learning sessions.',
  'can i learn cassava farming online?':
      'Yes, you can learn cassava farming online. Many agricultural organizations, universities, and research institutes offer online resources, guides, videos, and sometimes even free online courses on cassava cultivation, pest and disease management, and processing. YouTube channels by agricultural experts are also a good resource.',
  'are there mobile apps for cassava farming?':
      'Yes, there are mobile apps specifically developed for cassava farming, particularly for disease diagnosis (e.g., PlantVillage Nuru, which can detect CMD and CBSD using AI). Some apps also offer general farming advice, market information, or record-keeping tools relevant to cassava.',
  'can i talk to an agronomist about cassava?':
      'Yes, you can talk to an agronomist about cassava. Agronomists (or agricultural extension officers) are experts in crop production and can provide tailored advice on:\n'
      '• Variety selection\n'
      '• Soil management and fertilization\n'
      '• Pest and disease control\n'
      '• Best cultivation practices\n'
      'Contact your local Ministry of Food and Agriculture (MoFA) office in Ghana for extension services.',
  'where can i find cassava farming guides?':
      'You can find cassava farming guides from various sources:\n'
      '• Agricultural Research Institutes: Like CSIR-CRI (Ghana) or IITA (International Institute of Tropical Agriculture).\n'
      '• Government Agricultural Departments: Ministry of Food and Agriculture (MoFA) in Ghana.\n'
      '• Universities: Agricultural faculties.\n'
      '• NGOs: Involved in agricultural development.\n'
      '• Online Resources: Websites of the above organizations, agricultural blogs, and YouTube channels.',

  // 16. Research & Innovation
  'are there new varieties of disease-resistant cassava?':
      'Yes, significant research is ongoing, and new varieties of disease-resistant cassava are continuously being developed and released. Breeders focus on resistance to major diseases like Cassava Mosaic Disease (CMD) and Cassava Brown Streak Disease (CBSD), as well as improved yield and other desirable traits.',
  '’s the future of cassava farming?':
      'The future of cassava farming looks promising, driven by:\n'
      '• Climate Resilience: Its ability to thrive in changing climates.\n'
      '• Increased Demand: Growing demand for both food and industrial uses.\n'
      '• Biotechnology: Development of high-yielding, disease/pest-resistant, and biofortified varieties.\n'
      '• Mechanization: Increased use of machines for planting, weeding, and harvesting.\n'
      '• Value Addition: Expansion of processing into diverse, high-value products.',
  'can ai detect cassava diseases?':
      'Yes, Artificial Intelligence (AI) can detect cassava diseases. AI-powered mobile applications, such as PlantVillage Nuru, use image recognition and machine learning algorithms to analyze photos of cassava leaves and accurately identify common diseases like CMD and CBSD, providing farmers with quick and accessible diagnostic tools.',
  ' role does biotechnology play in cassava?':
      'Biotechnology plays a crucial role in cassava improvement, including:\n'
      '• Genetic Engineering: Developing genetically modified (GM) cassava with enhanced disease/pest resistance or nutritional content (e.g., biofortified Vitamin A cassava).\n'
      '• Marker-Assisted Selection (MAS): Accelerating conventional breeding by using DNA markers to select desirable traits.\n'
      '• Tissue Culture: Producing large quantities of disease-free planting material.\n'
      '• Genomics: Understanding the cassava genome to identify genes for important traits.',
  ' universities research cassava?':
      'Several universities globally and in Africa conduct significant research on cassava, often in collaboration with international research centers. Examples include:\n'
      '• University of Ghana, Legon (Ghana)\n'
      '• Kwame Nkrumah University of Science and Technology (KNUST, Ghana)\n'
      '• Cornell University (USA)\n'
      '• Makerere University (Uganda)\n'
      '• Federal University of Agriculture, Abeokuta (Nigeria)\n'
      'And many more, often working closely with research institutes like IITA and CIAT.',

  // 17. Gender & Inclusion
  'can women benefit from cassava farming?':
      'Yes, women can significantly benefit from cassava farming. In many African countries, women are the primary cultivators, processors, and marketers of cassava. Investing in women farmers through training, access to inputs, and processing technologies can greatly enhance their livelihoods, food security, and economic empowerment.',
  'are there support groups for female cassava farmers?':
      'Yes, there are often support groups, cooperatives, and associations specifically for female cassava farmers. These groups provide platforms for sharing knowledge, accessing resources, pooling labor, and collectively marketing their produce, enhancing their collective bargaining power and economic resilience. Local NGOs and agricultural extension services can help you find them.',
  'how can youth get into cassava farming?':
      'Youth can get into cassava farming by:\n'
      '• Adopting modern practices: Using improved varieties and sustainable techniques.\n'
      '• Focusing on value addition: Processing cassava into higher-value products.\n'
      '• Leveraging technology: Using mobile apps for diagnosis, drones for monitoring, and social media for marketing.\n'
      '• Accessing training and mentorship: Through agricultural programs and experienced farmers.\n'
      '• Forming cooperatives: To access land, finance, and markets collectively.',
  'are there cooperatives for cassava growers?':
      'Yes, farmer cooperatives for cassava growers are common. These cooperatives help farmers by:\n'
      '• Bulk purchasing inputs: Getting better prices on fertilizers and planting material.\n'
      '• Collective marketing: Selling produce together to get better prices.\n'
      '• Accessing credit and training: As a unified group.\n'
      '• Sharing resources: Like machinery or processing equipment.\n'
      '• Advocacy: Representing farmers\' interests.',
  'can cassava farming reduce poverty?':
      'Yes, cassava farming can significantly reduce poverty. As a resilient staple crop that can grow on marginal lands, it provides food security for vulnerable populations. It also generates income for millions of smallholder farmers and creates employment opportunities throughout its value chain, from cultivation to processing and marketing.',

  // 18. Finance & Support
  'can i get a loan for cassava farming?':
      'Yes, you can often get a loan for cassava farming from various financial institutions, including:\n'
      '• Commercial banks: Some banks have specific agricultural loan products.\n'
      '• Microfinance institutions: Often target smallholder farmers.\n'
      '• Agricultural development banks: Institutions specifically established to support the agricultural sector.\n'
      '• Government programs: Some governments offer subsidized loans or grants for agricultural ventures. Loan eligibility criteria and requirements will vary.',
  'are there grants for cassava projects?':
      'Yes, there are often grants available for cassava projects, especially those focused on:\n'
      '• Research and development: For improved varieties or sustainable practices.\n'
      '• Value chain development: Supporting processing and marketing initiatives.\n'
      '• Climate change adaptation: Projects promoting resilient cassava farming.\n'
      '• Food security and poverty reduction: Initiatives in vulnerable communities.\n'
      'These grants are typically offered by international development organizations, foundations, and government agencies.',
  'how much does it cost to start a cassava farm?':
      'The cost to start a cassava farm varies widely depending on size, location, intensity of cultivation, and level of mechanization. Key cost components include:\n'
      '• Land preparation: Clearing, ploughing, ridging.\n'
      '• Planting material: Cost of stem cuttings.\n'
      '• Inputs: Fertilizers, pesticides (if used).\n'
      '• Labor: For planting, weeding, harvesting.\n'
      '• Tools/Equipment: Hoes, cutlasses, or larger machinery.\n'
      'For a smallholder in Ghana, it could range from a few hundred to a few thousand Ghana cedis per acre, while larger commercial farms would require significantly more capital.',
  'profit margin on cassava?':
      'The profit margin on cassava can be highly variable. It depends on factors like:\n'
      '• Yield per hectare: Higher yields generally mean higher profits.\n'
      '• Market prices: Fluctuations in prices for fresh roots or processed products.\n'
      '• Cost of production: Efficient management of inputs and labor.\n'
      '• Value addition: Processing cassava into higher-value products typically increases profit margins compared to selling raw roots.\n'
      'Good management practices and market access are key to maximizing profitability.',
  'are there microfinancing options for cassava farmers?':
      'Yes, microfinancing options are widely available for smallholder cassava farmers, especially in rural areas. Microfinance institutions (MFIs) provide small loans, savings, and other financial services to low-income individuals and groups who typically lack access to conventional banking services, enabling them to invest in their farms and improve their livelihoods.',

  // 19. Safety & Ethics
  'is cassava toxic?':
      'Yes, raw cassava contains naturally occurring cyanogenic glycosides, which can release toxic hydrogen cyanide when processed or ingested. This is why proper processing (peeling, grating, soaking, fermenting, drying, cooking) is essential to remove or reduce these toxins to safe levels before consumption.',
  'how do i remove toxins from cassava?':
      'Toxins (cyanide) are removed from cassava through various processing methods:\n'
      '• Peeling and grating: Breaks down cell walls, allowing enzymes to act.\n'
      '• Soaking: Submerging in water for extended periods (e.g., 2-3 days) to leach out toxins.\n'
      '• Fermentation: Microorganisms break down glycosides (e.g., for gari, fufu).\n'
      '• Drying: Sun-drying or oven-drying reduces moisture and allows cyanide to volatilize.\n'
      '• Cooking: Boiling or frying further reduces residual cyanide. Combining methods (e.g., grating, fermenting, then frying for gari) is highly effective.',
  'can i feed raw cassava to animals?':
      'No, you should not feed raw cassava directly to animals. Like humans, animals are susceptible to cyanide poisoning from raw cassava. Cassava intended for animal feed must be properly processed (e.g., chipped and thoroughly dried, or fermented) to reduce its cyanogenic content to safe levels.',
  ' happens if humans eat raw cassava?':
      'If humans eat raw cassava, especially bitter varieties, they risk acute cyanide poisoning. Symptoms can appear quickly and include nausea, vomiting, abdominal pain, headache, dizziness, weakness, and difficulty breathing. In severe cases, it can lead to convulsions, coma, and even death. Chronic consumption of improperly processed cassava can lead to neurological disorders like Konzo.',
  'is all cassava safe to eat?':
      'Not all cassava is safe to eat in its raw form or with minimal processing. Cassava varieties are categorized as "sweet" (low cyanide) or "bitter" (high cyanide). While sweet varieties can be eaten after simple cooking (like boiling), bitter varieties must undergo extensive processing (like prolonged soaking, fermentation, and drying) to remove dangerous levels of cyanide before they are safe for consumption.',

  // 20. Tools & Technology
  ' farm tools do i need for cassava?':
      'Basic farm tools needed for cassava include:\n'
      '• Cutlass/Machete: For land clearing and harvesting stems.\n'
      '• Hoe: For land preparation, weeding, and mounding/ridging.\n'
      '• Spade/Digging Stick: For harvesting roots.\n'
      '• Wheelbarrow/Head Pan: For transporting harvested roots or inputs.\n'
      'For larger farms, tractors with ploughs, harrows, and ridgers, and potentially mechanical planters or harvesters, would be needed.',
  'are there machines for cassava harvesting?':
      'Yes, there are machines for cassava harvesting. These range from tractor-mounted diggers that loosen the soil and lift roots to more specialized, self-propelled cassava harvesters. While effective for large-scale commercial farms, they are still less common for smallholder farmers due to cost and suitability for varied terrain.',
  'can i plant cassava with a tractor?':
      'Yes, you can plant cassava with a tractor, especially on larger, well-prepared fields. Tractor-mounted planters can efficiently create ridges and plant stem cuttings, significantly reducing labor and time compared to manual planting. This is a common practice in commercial cassava farming.',
  'are there mobile apps for disease diagnosis?':
      'Yes, as mentioned, there are mobile apps specifically for cassava disease diagnosis. A notable example is PlantVillage Nuru, developed by Penn State University and partners, which uses artificial intelligence to identify Cassava Mosaic Disease and Cassava Brown Streak Disease from photos of leaves, providing real-time feedback to farmers.',
  'can drones help in cassava farming?':
      'Yes, drones can help in cassava farming, particularly in larger or commercial operations, by:\n'
      '• Mapping and monitoring: Providing aerial views of farm health, stand establishment, and problem areas.\n'
      '• Disease/Pest detection: Identifying stressed plants or disease outbreaks early.\n'
      '• Precision agriculture: Guiding targeted application of fertilizers or pesticides.\n'
      '• Yield estimation: Using imagery to predict harvest volumes.',

  // 21. Monitoring & Record-Keeping
  'how do i track cassava yields?':
      'To track cassava yields:\n'
      '1. Measure plot size: Accurately determine the area harvested.\n'
      '2. Weigh harvest: Weigh the fresh roots harvested from that measured plot.\n'
      '3. Calculate: Convert the weight to tonnes per hectare (1 hectare = 10,000 square meters) by scaling up your measured plot yield. Keep records for each harvest and plot.',
  ' records should i keep?':
      'For effective farm management, you should keep records of:\n'
      '• Planting details: Date, variety, spacing, planting material source.\n'
      '• Inputs: Fertilizer type, amount, application date; pesticide type, amount, date.\n'
      '• Labor: Hours worked, tasks performed, cost.\n'
      '• Harvest details: Date, yield (weight), plot harvested.\n'
      '• Pest/Disease observations: Dates, symptoms, management actions taken.\n'
      '• Rainfall/Irrigation: Records of water received/applied.\n'
      '• Sales: Dates, quantity sold, price received.',
  'how can i calculate cost per acre?':
      'To calculate the cost per acre (or per hectare):\n'
      '1. Sum all expenses: Add up all costs incurred for that specific acre/hectare (land prep, planting material, fertilizer, labor, pest control, etc.).\n'
      '2. Divide by area: Divide the total expenses by the acreage/hectare to get the cost per unit area.\n'
      'This helps you understand profitability and make informed decisions.',
  'can i use excel or apps for tracking?':
      'Yes, absolutely! Using Excel spreadsheets or dedicated farm management apps is highly recommended for tracking cassava farming data. They allow for organized data entry, easy calculations, and visual representation of trends, helping you analyze performance, costs, and profitability more effectively than manual record-keeping.',
  'should i use gps for mapping cassava plots?':
      'Using GPS for mapping cassava plots is highly beneficial, especially for larger or commercial farms. It allows you to:\n'
      '• Accurately define boundaries: Precisely measure plot sizes.\n'
      '• Plan field operations: Optimize planting patterns and irrigation.\n'
      '• Monitor spatial variations: Identify areas with different yields or problems.\n'
      '• Record data: Link field data to specific geographical locations for better analysis and decision-making.',

  // 22. Business & Strategy
  'can i turn cassava farming into a business?':
      'Yes, you can definitely turn cassava farming into a profitable business. It requires a strategic approach focusing on:\n'
      '• Commercial varieties: Planting high-yielding varieties.\n'
      '• Good agricultural practices: Maximizing yield and quality.\n'
      '• Value addition: Processing roots into gari, flour, or starch to increase income.\n'
      '• Market linkages: Securing reliable buyers for your produce.\n'
      '• Business planning: Managing costs, finances, and marketing effectively.',
  'how much land do i need for profit?':
      'The amount of land needed for profit from cassava farming depends on your target income, expected yield, and market prices. While small plots can provide supplementary income, for a significant commercial profit, you\'d generally need at least 1-5 hectares (2.5-12.5 acres) or more, coupled with efficient management and potential value addition.',
  ' risks in cassava business?':
      'Risks in the cassava business include:\n'
      '• Pests and Diseases: Outbreaks can devastate yields.\n'
      '• Market Price Fluctuations: Unpredictable prices for raw roots.\n'
      '• Post-Harvest Losses: Rapid perishability of fresh roots.\n'
      '• Climate Risks: Droughts or excessive rainfall.\n'
      '• Labor Costs: Manual operations can be expensive.\n'
      '• Access to Finance: Difficulty in securing capital for expansion or processing.',
  'can i start a cassava processing factory?':
      'Yes, you can start a cassava processing factory, but it requires substantial capital investment, technical expertise, and a guaranteed supply of raw cassava roots. Factories can produce products like gari, fufu flour, industrial starch, or even bioethanol, offering significant value addition and market opportunities.',
  'should i register a cassava brand?':
      'If you are producing and selling processed cassava products (e.g., packaged gari, HQCF, cassava snacks) beyond local, informal markets, then yes, registering a cassava brand is a good business strategy. It helps in:\n'
      '• Product differentiation: Standing out from competitors.\n'
      '• Building trust: Signifying quality and consistency.\n'
      '• Marketing and promotion: Creating a recognizable identity.\n'
      '• Legal protection: Preventing others from using your brand name.',

  // 23. Sustainability & Organic Farming
  'can i grow cassava organically?':
      'Yes, you can grow cassava organically. Organic cassava farming focuses on natural methods for soil fertility, pest, and weed management, avoiding synthetic fertilizers and pesticides. It relies on practices like:\n'
      '• Crop rotation with legumes.\n'
      '• Use of compost and organic manure.\n'
      '• Manual weeding and mulching.\n'
      '• Use of naturally resistant varieties and biological pest control.',
  ' eco-friendly methods of disease control?':
      'Eco-friendly methods of disease control for cassava include:\n'
      '• Using disease-resistant varieties: This is the most effective and sustainable method.\n'
      '• Sanitation: Removing and destroying infected plants promptly.\n'
      '• Crop rotation: To break disease cycles.\n'
      '• Healthy soil: Promoting plant vigor through organic matter and balanced nutrients.\n'
      '• Biological control: Encouraging natural enemies of vectors like whiteflies.',
  'does cassava farming contribute to sustainability?':
      'Cassava farming can contribute to sustainability when practiced responsibly. Its resilience, ability to grow on marginal lands, and role in food security are sustainable aspects. However, monoculture without nutrient replenishment or unsustainable land clearing can be detrimental. Sustainable practices like intercropping, agroforestry, and integrated nutrient management enhance its sustainability.',
  'how do i farm cassava without chemicals?':
      'To farm cassava without chemicals:\n'
      '• Choose resistant varieties: Select varieties naturally resistant to local pests and diseases.\n'
      '• Build soil health: Rely on compost, manure, and cover crops for fertility.\n'
      '• Practice crop rotation: To manage soil-borne pests and diseases.\n'
      '• Weed manually/mulch: Control weeds without herbicides.\n'
      '• Encourage beneficial insects: For natural pest control.\n'
      '• Use clean planting material: To prevent disease introduction.',
  'can cassava farming regenerate degraded land?':
      'Yes, cassava farming, particularly when integrated with sustainable practices, can play a role in regenerating degraded land. Its deep root system can help improve soil structure and prevent erosion. When combined with organic matter addition, cover cropping, and minimal tillage, it can help rehabilitate nutrient-depleted or eroded soils over time.',

  // 24. Troubleshooting
  'why is my cassava growing slowly?':
      'Slow cassava growth can be due to:\n'
      '• Poor soil fertility: Lack of essential nutrients, especially N and K.\n'
      '• Inadequate water: Drought stress.\n'
      '• Pest or disease infestation: Such as mealybugs, green mites, or viral diseases.\n'
      '• Poor planting material: Weak or unhealthy stem cuttings.\n'
      '• Weed competition: Weeds outcompeting young cassava plants.\n'
      '• Shading: Insufficient sunlight.',
  'why are my cassava leaves yellowing?':
      'Cassava leaves can yellow for several reasons:\n'
      '• Nutrient deficiency: Most commonly nitrogen (general yellowing of older leaves) or potassium (yellowing/scorching of leaf margins).\n'
      '• Drought stress: Leaves may turn yellow and wilt during prolonged dry periods.\n'
      '• Pest infestation: Green mites cause yellow mottling.\n'
      '• Disease: Cassava Mosaic Disease causes yellow mosaic patterns.\n'
      '• Aging: Natural yellowing and shedding of older leaves.',
  'why are cassava stems rotting?':
      'Cassava stems can rot due to:\n'
      '• Excessive moisture/Waterlogging: The most common cause, especially in poorly drained soils.\n'
      '• Fungal or bacterial infections: Specific pathogens can cause stem rot.\n'
      '• Damaged planting material: Rot can start from bruised or diseased cuttings.\n'
      '• High humidity and poor air circulation: Creating favorable conditions for pathogens.\n'
      '• Pest damage: Stem borers can create entry points for rot organisms.',
  'why is my yield lower than expected?':
      'Lower than expected cassava yield can be attributed to:\n'
      '• Poor variety selection: Using low-yielding or unsuitable varieties.\n'
      '• Pest and disease outbreaks: Uncontrolled infestations.\n'
      '• Poor soil fertility: Insufficient nutrients.\n'
      '• Inadequate rainfall/irrigation: Water stress during critical growth stages.\n'
      '• Suboptimal spacing: Too wide or too dense.\n'
      '• Poor weed control: Competition reducing resources for cassava.\n'
      '• Poor planting material: Unhealthy or damaged cuttings.',
  'why are cassava roots thin?':
      'Cassava roots may be thin due to:\n'
      '• Insufficient potassium (K): Potassium is crucial for root bulking and starch accumulation.\n'
      '• Early harvest: Roots not given enough time to mature and swell.\n'
      '• Poor soil compaction/hardpan: Restricting root expansion.\n'
      '• Severe pest or disease pressure: Stressing the plant and diverting energy from root development.\n'
      '• Poor soil fertility: General lack of nutrients affecting overall plant vigor.\n'
      '• Genetic factors: Some varieties naturally produce thinner roots.',

  // 25. Community & Help
  'where can i meet other cassava farmers?':
      'You can meet other cassava farmers at:\n'
      '• Local farmer cooperative meetings.\n'
      '• Agricultural extension office events or field days.\n'
      '• Local markets where cassava is sold.\n'
      '• Community gatherings or forums focused on agriculture.\n'
      '• Agricultural fairs and exhibitions.',
  'are there sapp groups for cassava farmers?':
      'Yes, it is common for agricultural extension officers, NGOs, or farmer associations to set up sApp groups for cassava farmers. These groups facilitate quick information sharing, problem-solving, market updates, and peer-to-peer support. You can inquire about such groups at your local agricultural office.',
  'is there government support for cassava?':
      'Yes, in many cassava-producing countries like Ghana, there is government support for the cassava sector. This often includes:\n'
      '• Extension services and training.\n'
      '• Promotion and distribution of improved varieties.\n'
      '• Subsidies on inputs (e.g., fertilizer).\n'
      '• Programs for value chain development and processing.\n'
      '• Research funding.\n'
      '• Policies aimed at boosting production and utilization (e.g., "Planting for Food and Jobs" in Ghana).',
  'can i get extension services in my region?':
      'Yes, you can get agricultural extension services in your region (Sunyani, Bono Region, Ghana). The Ministry of Food and Agriculture (MoFA) operates district and regional agricultural offices with extension officers who provide advice, training, and support to farmers on various crops, including cassava. Visit your nearest MoFA office.',
  'where can i report cassava disease outbreaks?':
      'You should report cassava disease outbreaks to your local:\n'
      '• Agricultural Extension Officer (MoFA in Ghana).\n'
      '• District or Regional Agricultural Department.\n'
      '• Nearest agricultural research institute (e.g., CSIR-CRI in Ghana).\n'
      'Early reporting helps in rapid response, containment, and prevents wider spread of diseases.',

  'who introduced cassava to africa?':
      'Cassava was introduced to Africa by Portuguese traders in the 16th century from its origin in South America (specifically the Amazon basin). It quickly spread across the continent due to its adaptability and high yield, becoming a staple crop in many African countries.',
  'is cassava a tuber or a root?':
      'Cassava is technically a root crop, specifically a storage root. While often mistakenly called a tuber, tubers (like potatoes) are swollen underground stems, whereas cassava\'s edible part develops from swollen adventitious roots.',
  'can cassava grow in containers?':
      'Yes, cassava can be grown in containers, though it typically won\'t reach the same size or yield as field-grown plants. For container growing, use large pots (at least 15-20 gallons or 60-80 liters) with good drainage, well-draining potting mix, and ensure adequate sunlight, water, and nutrients.',
  'is cassava affected by climate change?':
      'Yes, cassava is affected by climate change, though it is one of the most resilient crops. While it tolerates drought, increased frequency of extreme weather events (prolonged droughts, intense floods) and changes in temperature can impact yields. Climate change also influences the spread and severity of pests (like whiteflies) and diseases (like CBSD), which are major threats to cassava.',
  ' country grows the most cassava?':
      'Nigeria is the country that grows the most cassava globally, producing significantly more than any other nation. Other major producers include Democratic Republic of Congo, Thailand, Indonesia, Brazil, and Angola.',
  ' cassava?':
      'Cassava (Manihot esculenta) is a woody shrub of the Euphorbiaceae (spurge) family, extensively cultivated as an annual crop in tropical and subtropical regions for its edible starchy tuberous root, a major source of carbohydrates.',
  'how long does cassava take to grow?':
      'Cassava typically takes between 8 to 24 months to grow, depending on the variety, desired root size, and growing conditions. Early-maturing varieties can be harvested from 8 months, while late-maturing ones can take up to 24 months.',
  ' the main varieties of cassava?':
      'Main varieties of cassava include local landraces, and improved varieties developed through breeding programs. Some popular improved varieties in Africa are TME 419, TMS 30572, and various Vitamin A biofortified (yellow-fleshed) varieties. They are often classified as "sweet" or "bitter" based on their cyanide content.',
  'which cassava variety grows fastest?':
      'Generally, early-maturing cassava varieties grow fastest, producing harvestable roots within 8 to 12 months. Examples include some improved varieties specifically bred for quick maturity, though specific performance varies by region and conditions.',
  ' the nutritional values of cassava?':
      'Cassava is primarily a source of carbohydrates, providing high energy. It also contains some dietary fiber, Vitamin C, and small amounts of B vitamins and minerals like calcium, phosphorus, and iron. It is low in protein and fat, so it should be consumed with other food groups for a balanced diet.',
  ' cassava\'s uses besides food?':
      'Besides food, cassava is widely used for:\n'
      '• Animal Feed: Dried roots (chips/pellets) and processed leaves are excellent feed for livestock and poultry.\n'
      '• Industrial Starch: Used in textiles (sizing), paper production, adhesives, pharmaceuticals, and as a thickener in various industries.\n'
      '• Bioethanol: Its high starch content makes it a viable feedstock for bioethanol production.\n'
      '• Other: Leaves can be consumed as a vegetable (after proper processing), and stems are used as planting material for the next season.',
  'can cassava grow in poor soil?':
      'Yes, cassava is remarkably tolerant of poor soils, including those with low fertility and acidity, where many other crops would struggle. However, it performs best and yields higher in well-drained, fertile loamy soils. Improving soil fertility will always lead to better yields.',
  'how deep do cassava roots grow?':
      'Cassava roots, particularly the fibrous and non-storage roots, can grow quite deep, often reaching depths of 1-2 meters (3-6 feet) or more, especially in loose soils. The storage roots (the edible part) typically develop in the upper 30-60 cm (1-2 feet) of the soil.',
  'how many tonnes per hectare can i expect?':
      'Expected cassava yields vary significantly. For smallholder farmers using traditional methods, 10-25 tonnes per hectare is common. With improved varieties, good soil fertility, and proper management practices, yields can range from 30-50 tonnes per hectare, and even higher under optimal conditions.',
  'how do i identify good cassava planting materials?':
      'Good cassava planting materials (stem cuttings) should be:\n'
      '• From healthy, mature (8-18 months old), disease-free plants.\n'
      '• Obtained from the middle, woody part of the stem.\n'
      '• Approximately 20-25 cm (8-10 inches) long with 5-7 nodes.\n'
      '• Free from cracks, damage, or insect holes.\n'
      '• Plump and greenish-brown, not shriveled or dry.',

  // 2. Planting & Cultivation
  'best time to plant cassava?':
      'The best time to plant cassava is typically at the beginning of the rainy season. This ensures that the cuttings receive sufficient moisture for sprouting and initial growth, leading to better establishment and higher yields.',
  'how do i prepare land for cassava planting?':
      'Land preparation for cassava involves:\n'
      '• Clearing: Removing existing vegetation, stumps, and debris.\n'
      '• Ploughing & Harrowing: Tilling the soil to a fine tilth, which improves aeration and root penetration.\n'
      '• Ridging/Mounding: Creating ridges or mounds is often recommended, especially in areas prone to waterlogging, as it improves drainage and facilitates root development and harvesting.',
  '’s the recommended spacing for cassava?':
      'Recommended spacing for cassava varies based on variety, soil fertility, and intended use. Common spacing ranges from:\n'
      '• 1m x 1m (10,000 plants/hectare) for vigorous varieties.\n'
      '• 0.8m x 0.8m (15,625 plants/hectare) for less vigorous varieties or when aiming for higher root numbers.\n'
      '• Denser spacing (e.g., 0.75m x 0.75m) may be used for specific purposes like early harvest or leafy vegetable production.',
  'can cassava be grown with other crops?':
      'Yes, cassava is highly suitable for intercropping (growing with other crops simultaneously). Common companion crops include legumes (e.g., groundnuts, cowpea, beans), maize, and vegetables. Intercropping can improve soil fertility, suppress weeds, diversify income, and optimize land use.',
  ' ideal climatic conditions for cassava?':
      'Ideal climatic conditions for cassava include:\n'
      '• Temperature: Warm temperatures, optimally between 25°C and 30°C (77°F-86°F).\n'
      '• Rainfall: Well-distributed annual rainfall of 1000-1500 mm (40-60 inches), though it can tolerate lower amounts.\n'
      '• Sunlight: Full sunlight is preferred for optimal growth and root development.',
  'can cassava grow in dry regions?':
      'Yes, cassava is renowned for its remarkable drought tolerance and is often considered a "famine reserve" crop. It can survive and produce a yield even under prolonged dry spells where many other crops would fail, making it crucial for food security in arid and semi-arid regions.',
  'should i till the land before planting cassava?':
      'Tilling the land before planting cassava is generally recommended as it helps create a loose, aerated soil structure, which is conducive to root development and easier harvesting. However, in some conservation agriculture systems, minimum tillage or no-till methods with mulching can also be effective.',
  'can i use cassava cuttings more than once?':
      'No, you cannot use the same cassava cutting more than once for planting. Once a stem cutting has sprouted and grown into a plant, its function as a planting material is complete. New cuttings must be taken from healthy, mature stems of existing plants for subsequent plantings.',
  'how do i treat cassava stems before planting?':
      'Treating cassava stems before planting can improve establishment and reduce disease. Methods include:\n'
      '• Dipping in fungicide/insecticide: To protect against soil-borne diseases and early pest attacks (use approved chemicals and follow safety guidelines).\n'
      '• Soaking: Brief soaking in water can rehydrate cuttings, especially if they have been stored for some time.\n'
      '• Wound healing (Curing): Allowing cuttings to dry for a day or two in the shade to form a callus on the cut ends can reduce rot, though this is less common for routine planting.',
  'how can i improve soil fertility before planting?':
      'You can improve soil fertility before planting cassava by:\n'
      '• Adding Organic Matter: Incorporating compost, farmyard manure, or crop residues.\n'
      '• Crop Rotation: Rotating with legumes or other crops that improve soil health.\n'
      '• Liming: If the soil is too acidic, apply agricultural lime to raise the pH.\n'
      '• Green Manuring: Growing and incorporating a cover crop specifically to enrich the soil.\n'
      '• Balanced Fertilization: Applying basal fertilizers based on soil test recommendations.',

  // 3. Fertilizers & Nutrients
  'does cassava need fertilizer?':
      'While cassava can tolerate low-fertility soils, it is a nutrient-demanding crop, especially for potassium. Applying fertilizers, whether organic or inorganic, is highly recommended to achieve optimal yields and maintain long-term soil productivity.',
  'best fertilizer for cassava?':
      'The best fertilizer for cassava depends on your soil test results. However, cassava generally responds well to a balanced NPK (Nitrogen, Phosphorus, Potassium) fertilizer, with a particular need for Potassium (K). High-potassium fertilizers are often recommended.',
  'when should i apply fertilizer?':
      'For optimal results, fertilizer for cassava should typically be applied in two splits:\n'
      '• Basal Application: At planting or within 2-4 weeks after planting, to support initial growth.\n'
      '• Top-dressing: Around 3-4 months after planting, when the roots begin to tuberize and the plant has a high nutrient demand.',
  'is organic manure good for cassava?':
      'Yes, organic manure (like compost or farmyard manure) is excellent for cassava. It not only provides essential nutrients but also improves soil structure, water retention, and microbial activity, leading to healthier plants and sustained soil fertility.',
  'how often should i fertilize cassava?':
      'For best results, cassava is typically fertilized once or twice during its growth cycle, as described above (basal and top-dressing). Annual application is sufficient for a single cropping cycle.',
  'can i use compost for cassava?':
      'Absolutely! Compost is a highly beneficial amendment for cassava. It slowly releases nutrients, improves soil tilth, and enhances soil biology, contributing to vigorous growth and better yields. Incorporate it during land preparation or as a top-dressing.',
  'how do i test my soil before fertilizing?':
      'To test your soil before fertilizing:\n'
      '1. Collect Samples: Take several small samples from different spots across your field (avoiding unusual areas).\n'
      '2. Mix & Prepare: Mix these samples thoroughly to get a composite sample, then remove debris and air dry.\n'
      '3. Send to Lab: Send the sample to a reputable agricultural testing laboratory. They will analyze for pH, NPK, and micronutrient levels, providing recommendations for fertilizer application.',
  ' nutrients does cassava need most?':
      'Cassava needs Potassium (K) most, followed by Nitrogen (N) and Phosphorus (P). Potassium is crucial for root development and starch accumulation. It also requires micronutrients like zinc and boron, though in smaller quantities.',
  ' signs of nutrient deficiency in cassava?':
      'Signs of nutrient deficiency in cassava include:\n'
      '• Nitrogen (N): General yellowing of older leaves, stunted growth.\n'
      '• Phosphorus (P): Purplish discoloration of leaves (especially older ones), slow growth, poor root development.\n'
      '• Potassium (K): Yellowing and browning/scorching of leaf margins, particularly on older leaves, and reduced root size.\n'
      '• Micronutrients: Specific symptoms like interveinal chlorosis (yellowing between veins) on younger leaves for iron or zinc deficiency.',
  'can cassava grow without any fertilizer?':
      'Yes, cassava can grow without any added fertilizer, especially in relatively fertile soils or areas with long fallow periods. However, yields will likely be significantly lower than with proper nutrient management, and continuous cropping without fertilization will deplete soil nutrients over time.',

  // 4. Water & Irrigation
  'does cassava need irrigation?':
      'While cassava is known for its drought tolerance, it does benefit significantly from adequate moisture, especially during establishment and critical growth phases (first 3-4 months and during root bulking). Irrigation can boost yields, particularly in areas with erratic rainfall or prolonged dry seasons.',
  'how often should i water cassava?':
      'The frequency of watering depends on rainfall, soil type, and climate. During dry periods, especially in the first few months after planting, providing water once or twice a week (or as needed to keep the soil moist but not waterlogged) is beneficial. Established plants are more tolerant of dry spells.',
  'can cassava survive drought?':
      'Yes, cassava is highly resilient to drought. It can shed leaves to conserve moisture and re-sprout when rains return, allowing it to survive prolonged dry periods and still produce a reasonable yield, making it a vital food security crop in drought-prone areas.',
  'how do i irrigate cassava in dry seasons?':
      'To irrigate cassava in dry seasons, consider:\n'
      '• Drip Irrigation: Most efficient, delivering water directly to the plant roots, minimizing waste.\n'
      '• Furrow Irrigation: If feasible, running water down furrows between rows.\n'
      '• Manual Watering: For small plots, direct application with watering cans or hoses.\n'
      '• Mulching: Apply organic mulch around plants to conserve soil moisture and reduce evaporation.',
  'does overwatering affect cassava growth?':
      'Yes, overwatering or waterlogged conditions severely affect cassava growth. Cassava roots are highly susceptible to rot in saturated soils, leading to poor root development, nutrient uptake issues, and eventually plant death. Good drainage is crucial.',

  // 5. Pests & Diseases
  ' the common diseases in cassava?':
      'The common and most devastating diseases in cassava are:\n'
      '1. Cassava Mosaic Disease (CMD): Viral, transmitted by whiteflies and infected cuttings.\n'
      '2. Cassava Brown Streak Disease (CBSD): Viral, transmitted by whiteflies and infected cuttings, causes root necrosis.\n'
      '3. Cassava Bacterial Blight (CBB): Bacterial, causes angular leaf spots and blight.\n'
      '4. Cassava Anthracnose Disease (CAD): Fungal, causes cankers and dieback on stems.',
  'how do i prevent cassava mosaic disease?':
      'To prevent Cassava Mosaic Disease (CMD):\n'
      '• Use resistant varieties: Plant CMD-resistant cassava varieties.\n'
      '• Disease-free planting material: Use only healthy, certified virus-free stem cuttings.\n'
      '• Rogueing: Regularly remove and destroy infected plants immediately upon identification.\n'
      '• Whitefly control: Manage whitefly populations, as they are the primary vectors.',
  ' causes cassava brown streak?':
      'Cassava Brown Streak Disease (CBSD) is caused by two main viruses: Ugandan Cassava Brown Streak Virus (UCBSV) and Cassava Brown Streak Virus (CBSV). It is primarily spread through infected planting material (stem cuttings) and by whiteflies (Bemisia tabaci).',
  'how do i identify cassava blight?':
      'Cassava Bacterial Blight (CBB) is identified by:\n'
      '• Angular water-soaked spots: Appearing on leaves, often along veins, which later turn brown and necrotic.\n'
      '• Blight: Large, irregular necrotic areas on leaves, leading to wilting and defoliation.\n'
      '• Gummy exudates: Small, sticky, amber-colored drops of bacterial ooze on stems and petioles.\n'
      '• Dieback: In severe cases, stem and branch dieback can occur.',
  ' green mite in cassava?':
      'The Cassava Green Mite (Mononychellus tanajoa) is a tiny, spider-like pest that feeds on the underside of cassava leaves. Infestation causes characteristic yellowing, distortion, and puckering of leaves, especially on new growth, leading to reduced leaf area and significant yield losses, particularly during dry seasons.',
  ' cassava mealybugs?':
      'Cassava mealybugs (Phenacoccus manihoti) are small, soft-bodied insects covered in a white, waxy, cottony substance. They feed on plant sap, primarily on the growing tips, young leaves, and stems, causing severe stunting, leaf distortion, and a characteristic "bunchy top" appearance, and can lead to significant yield loss.',
  'how can i prevent cassava diseases organically?':
      'To prevent cassava diseases organically:\n'
      '• Use resistant varieties: Prioritize varieties known for natural resistance.\n'
      '• Strict sanitation: Use only healthy, disease-free planting material. Rogue and destroy infected plants promptly.\n'
      '• Crop rotation: Break disease cycles by rotating cassava with non-host crops.\n'
      '• Healthy soil: Maintain vigorous plant health through good soil fertility (e.g., compost, manure) to increase natural resilience.\n'
      '• Biological control: Encourage natural predators of whiteflies (vectors).',
  ' chemicals control cassava pests?':
      'Chemicals (pesticides/insecticides) can control some cassava pests, but their use is generally discouraged due to environmental and health concerns, and ineffectiveness against viral vectors. Examples include:\n'
      '• Acaricides: For severe green mite infestations.\n'
      '• Systemic insecticides: To control whiteflies or mealybugs, but often not economically viable or effective for viral transmission.\n'
      'Always use approved chemicals, follow label instructions carefully, and consider Integrated Pest Management (IPM) approaches.',
  ' biological control options for cassava?':
      'Biological control options for cassava include:\n'
      '• Natural Enemies: Introducing or conserving natural predators and parasitoids (e.g., parasitic wasps for mealybugs or whiteflies; predatory mites for green mites).\n'
      '• Biopesticides: Use of microbial agents (e.g., fungi that infect insects) where appropriate.\n'
      'The parasitic wasp *Anagyrus lopezi* was very successful in controlling the cassava mealybug in Africa.',
  'can pests reduce cassava yield?':
      'Yes, pests can significantly reduce cassava yield. Severe infestations by pests like cassava green mite or mealybugs can cause defoliation, stunted growth, and direct damage to roots, leading to substantial yield losses and reduced quality.',

  // 6. Disease Identification
  ' do cassava mosaic symptoms look like?':
      'Cassava Mosaic Disease (CMD) symptoms look like:\n'
      '• Mosaic patterns: Distinct yellow or pale green patches alternating with normal green areas on the leaves.\n'
      '• Leaf distortion: Leaves may appear crumpled, twisted, or misshapen.\n'
      '• Stunting: Severely infected plants are often stunted with reduced leaf size and overall vigor.\n'
      '• Reduced root yield: Infected plants produce small, woody, or no edible roots.',
  'how do i know if my cassava has brown streak?':
      'You can know if your cassava has brown streak disease (CBSD) by observing these symptoms:\n'
      '• Leaf symptoms: Yellowing or browning along the leaf veins, forming distinct streaks, often more pronounced on older leaves.\n'
      '• Stem symptoms: Dark brown, necrotic lesions on woody stems, sometimes causing dieback.\n'
      '• Root symptoms (most critical): Internal, dark brown, necrotic streaks or rot within the storage roots, making them unpalatable and woody. Roots may also be constricted.',
  ' root rot in cassava?':
      'Root rot in cassava refers to the decay and disintegration of the storage roots, typically caused by fungal or bacterial pathogens. It often occurs in waterlogged soils, soils with poor drainage, or if roots are damaged during harvest, leading to significant post-harvest losses or pre-harvest plant death.',
  'best way to inspect cassava for disease?':
      'The best way to inspect cassava for disease is to:\n'
      '• Regularly scout: Walk through your farm frequently, observing plants closely.\n'
      '• Check all parts: Inspect leaves (upper and lower surfaces), stems, and even roots (if suspecting CBSD or root rot).\n'
      '• Focus on new growth: Viral diseases like CMD often manifest clearly on newly emerging leaves.\n'
      '• Look for patterns: Note if symptoms are widespread, patchy, or localized, which can give clues about the disease.\n'
      '• Consult experts: If unsure, take clear photos or samples to an agricultural extension officer or plant pathologist.',
  'can i scan cassava leaves with an app?':
      'Yes, there are emerging mobile applications (apps) designed to help farmers diagnose cassava diseases by scanning leaves with their smartphone cameras. These apps often use artificial intelligence and image recognition to identify common diseases like Cassava Mosaic Disease and Cassava Brown Streak Disease, providing instant feedback and management advice.',

  // 7. Weed Management
  'how do i control weeds in cassava?':
      'Effective weed control in cassava can be achieved through a combination of methods:\n'
      '• Manual Weeding: Using hoes or hands, especially in the early stages.\n'
      '• Mechanical Weeding: Using cultivators or tractors between rows in larger fields.\n'
      '• Herbicides: Applying pre-emergent or post-emergent herbicides (ensure proper product selection and application).\n'
      '• Mulching: Applying organic materials (straw, crop residues) around plants to suppress weeds and conserve moisture.\n'
      '• Intercropping: Growing companion crops that suppress weeds.',
  'can i use herbicides in cassava fields?':
      'Yes, herbicides can be used in cassava fields to control weeds, especially in larger operations. However, it\'s crucial to:\n'
      '• Choose appropriate herbicides: Select products specifically registered for cassava and target your prevalent weed types.\n'
      '• Follow label instructions: Adhere strictly to recommended dosages, application timing, and safety precautions.\n'
      '• Consider environmental impact: Minimize drift and potential harm to non-target plants or water sources.',
  '’s the best manual method for weed control?':
      'The best manual method for weed control in cassava is hoeing. Regular and shallow hoeing, especially during the first 2-3 months after planting, is highly effective in controlling weeds before they compete significantly with the young cassava plants. Hand-pulling can be used for weeds very close to the plants.',
  'how often should i weed cassava farms?':
      'Weeding cassava farms is most critical during the first 2-4 months after planting, as young cassava plants are poor competitors with weeds. During this period, 2-3 weeding cycles may be necessary. After the canopy closes, the cassava plants themselves help suppress weeds, reducing the need for further weeding.',
  'can weeds affect cassava yield?':
      'Yes, weeds can significantly affect cassava yield. Uncontrolled weed growth, especially in the early stages, competes directly with cassava plants for water, nutrients, and sunlight, leading to stunted growth, reduced root development, and substantial yield losses.',

  // 8. Growth & Monitoring
  'how can i tell if my cassava is growing well?':
      'You can tell if your cassava is growing well by observing:\n'
      '• Vigorous growth: Healthy, upright stems and abundant, dark green leaves.\n'
      '• Good branching: Strong, well-developed branches.\n'
      '• Absence of symptoms: No signs of pests, diseases, or nutrient deficiencies.\n'
      '• Canopy closure: The leaves forming a dense canopy that shades the ground, indicating good growth and weed suppression.',
  'ideal height of a cassava plant?':
      'The ideal height of a cassava plant varies greatly by variety and growing conditions. Generally, healthy cassava plants can reach heights of 1.5 to 3 meters (5 to 10 feet) at maturity. Excessive height with sparse leaves might indicate stretching for light or poor root development.',
  'how long until cassava matures?':
      'Cassava typically reaches physiological maturity and is ready for harvest between 8 to 24 months after planting. Early-maturing varieties can be harvested from 8 months, while some traditional and late-maturing varieties may take up to 18-24 months for optimal root development.',
  ' growth stages does cassava go through?':
      'Cassava goes through several key growth stages:\n'
      '1. Establishment (0-2 months): Sprouting of cuttings, root initiation, and initial leaf development.\n'
      '2. Vegetative Growth (2-6 months): Rapid stem and leaf growth, branching.\n'
      '3. Root Bulking/Tuberization (6-12+ months): Accumulation of starch in the roots, leading to their swelling.\n'
      '4. Maturity (8-24 months): Roots reach desired size and starch content.',
  'when should cassava leaves be pruned?':
      'Cassava leaves are generally not pruned for root production, as leaves are essential for photosynthesis and root development. However, pruning may be done for:\n'
      '• Disease management: Removing infected leaves or branches.\n'
      '• Harvesting leaves: If the leaves are intended for consumption as a vegetable (though this can reduce root yield).\n'
      '• Promoting branching: In some systems, topping plants early can encourage branching for increased stem production.',

  // 9. Harvesting
  'when is cassava ready for harvest?':
      'Cassava is ready for harvest when the roots have reached a desirable size and starch content, typically between 8 to 24 months after planting. Signs include some yellowing of lower leaves and maturity specific to the variety. Unlike many crops, cassava can often be left in the ground for several months after maturity, serving as a "food bank."',
  'how do i harvest cassava without damage?':
      'To harvest cassava roots without damage:\n'
      '• Loosen soil: Carefully loosen the soil around the base of the plant using a hoe or digging stick.\n'
      '• Pull gently: Grasp the stem firmly near the base and pull upwards with a steady, strong motion. For larger plants, multiple people or leverage may be needed.\n'
      '• Avoid breaking roots: Try to minimize breaking the roots, as damage reduces their shelf life.\n'
      '• Mechanical harvesters: For large-scale farms, specialized mechanical harvesters can lift roots, reducing manual labor and damage.',
  'can i harvest cassava in parts?':
      'Yes, you can harvest cassava in parts, which is one of its unique advantages. This practice is known as "piecemeal harvesting" or "gradual harvesting." You can dig up individual mature roots while leaving others in the ground to continue growing or for later harvest, allowing for continuous supply and acting as a living storage system.',
  ' signs that cassava is overripe?':
      'While cassava can stay in the ground for an extended period, if left for too long (e.g., beyond 24-36 months for some varieties), it can become "overripe." Signs include:\n'
      '• Woodiness/Fibrousness: Roots become harder, more fibrous, and difficult to cook or process.\n'
      '• Reduced palatability: Taste may become less desirable.\n'
      '• Lower starch content: Starch may convert to fiber.',
  'how long can cassava stay in the ground?':
      'Cassava can typically stay in the ground for an extended period after maturity, often for 6-12 months, and sometimes even up to 24 months or more, depending on the variety and environmental conditions. This "field storage" acts as a valuable food reserve and is a key advantage of the crop.',

  // 10. Post-Harvest
  'how do i store cassava roots?':
      'Fresh cassava roots have a very short shelf life (1-3 days) after harvest. To store them:\n'
      '• Leave in ground (field storage): Most common and effective.\n'
      '• Curing: Store undamaged roots in moist sand, sawdust, or soil, in a cool, dark place to allow wounds to heal.\n'
      '• Waxing/Coating: Applying wax or paraffin can reduce moisture loss.\n'
      '• Refrigeration: For short periods, refrigeration can extend freshness.\n'
      '• Processing: The most effective long-term storage is processing into stable products like flour, gari, or chips.',
  'how long does cassava last after harvest?':
      'Fresh, unpeeled cassava roots typically last only 1 to 3 days after harvest at ambient temperatures before they start to deteriorate rapidly due to physiological deterioration (cyanide release, enzymatic browning) and microbial spoilage. Peeling and processing immediately is crucial for longer preservation.',
  'can cassava be preserved?':
      'Yes, cassava can be preserved effectively by processing it into stable forms. Common preservation methods include:\n'
      '• Drying: Sun-drying or mechanical drying to produce chips or flour.\n'
      '• Fermentation: For products like gari or fufu, which also detoxifies the roots.\n'
      '• Freezing: Peeled and cut cassava can be frozen for extended periods.\n'
      '• Waxing/Curing: For very short-term fresh root storage.',
  'how do i process cassava into flour?':
      'Processing cassava into flour (High Quality Cassava Flour - HQCF) typically involves:\n'
      '1. Peeling & Washing: Removing the outer skin and cleaning roots.\n'
      '2. Grating: Reducing roots to a fine mash.\n'
      '3. Pressing/Dewatering: Removing excess water from the mash.\n'
      '4. Sieving/Pulverizing: Breaking up the dewatered cake into fine granules.\n'
      '5. Drying: Sun-drying or using mechanical dryers to reduce moisture content to below 10-12%.\n'
      '6. Milling/Grinding: Grinding the dried chips/granules into a fine flour.\n'
      '7. Packaging: Storing in airtight bags.',
  'can cassava be dried for storage?':
      'Yes, drying is one of the most common and effective ways to store cassava for long periods. Roots are peeled, chipped, and then sun-dried or mechanically dried until their moisture content is low enough to prevent spoilage (typically below 10-12%). These dried chips can then be stored or milled into flour.',

  // 11. Processing & Value Addition
  ' products can i make from cassava?':
      'A wide range of products can be made from cassava, adding significant value:\n'
      '• Food Products: Gari, fufu, attieke, cassava flour (for baking), starch, tapioca, bread, chips, and various traditional dishes.\n'
      '• Animal Feed: Pellets, chips, and leaf meal.\n'
      '• Industrial Products: Industrial starch (for paper, textiles, adhesives, pharmaceuticals), glucose syrup, bioethanol, and composite materials.',
  'garri made from cassava?':
      'Making gari from cassava involves several steps:\n'
      '1. Peeling & Washing: Removing the skin and cleaning the roots.\n'
      '2. Grating: Reducing the roots into a mash.\n'
      '3. Fermentation & Dewatering: Placing the mash in sacks, allowing it to ferment naturally (for 2-3 days) while simultaneously pressing out water.\n'
      '4. Sieving: Separating the fermented mash into fine granules.\n'
      '5. Toasting/Frying: Frying the granules in a hot pan (traditionally an iron pan) to cook and dry them into the final granular gari product.\n'
      '6. Cooling & Packaging: Allowing gari to cool before packaging.',
  ' fufu and it made?':
      'Fufu is a staple food in many parts of West and Central Africa, made by pounding starchy foods into a soft, dough-like consistency. When made from cassava, it typically involves:\n'
      '1. Boiling/Steaming: Peeled cassava roots are boiled or steamed until very soft.\n'
      '2. Pounding: The cooked cassava is then pounded in a mortar with a pestle until a smooth, cohesive dough is formed. (Alternatively, "fufu flour" is made from dried cassava which is then reconstituted and stirred in hot water to achieve a similar consistency).',
  'can cassava be used for animal feed?':
      'Yes, cassava is widely used for animal feed, especially for pigs, poultry, and ruminants. The roots are chipped, dried (pellets or meal) as an energy source, replacing maize in diets. Cassava leaves, after proper processing (e.g., wilting, sun-drying) to reduce cyanide, are a good source of protein and vitamins for livestock.',
  'can i produce ethanol from cassava?':
      'Yes, you can produce ethanol from cassava. Cassava\'s high starch content makes it an excellent feedstock for bioethanol production. The process involves converting the starch into fermentable sugars, which are then fermented by yeast to produce ethanol, followed by distillation and dehydration.',

  // 12. Marketing & Sales
  'where can i sell cassava?':
      'You can sell cassava in various markets:\n'
      '• Local Markets: Directly to consumers or local vendors.\n'
      '• Wholesale Markets: To larger traders who distribute to urban centers.\n'
      '• Processors: To factories that produce gari, fufu flour, starch, or animal feed.\n'
      '• Restaurants/Hotels: Supplying fresh roots or specific processed products.\n'
      '• Export Markets: For processed products like starch or HQCF, depending on quality and demand.',
  'current market price of cassava?':
      'The current market price of cassava varies significantly by region, season, variety, and whether it\'s fresh or processed. Prices are usually higher during the lean season (when supply is low) and lower during the peak harvest season. It\'s best to check with local market authorities or agricultural extension services for the most up-to-date prices in your specific area (e.g., Sunyani, Bono Region).',
  'how can i export cassava?':
      'Exporting cassava, especially processed products like High Quality Cassava Flour (HQCF) or starch, involves:\n'
      '1. Meeting Quality Standards: Ensuring products meet international food safety and quality regulations.\n'
      '2. Market Research: Identifying target markets and their specific import requirements.\n'
      '3. Logistics: Arranging for transport, customs clearance, and cold chain (if applicable).\n'
      '4. Documentation: Obtaining necessary export permits, certificates of origin, and phytosanitary certificates.\n'
      '5. Networking: Connecting with international buyers or export agents.',
  ' companies buy cassava in bulk?':
      'Companies that buy cassava in bulk typically include:\n'
      '• Industrial Starch Manufacturers: For use in food, textile, paper, and pharmaceutical industries.\n'
      '• Ethanol Producers: For biofuel production.\n'
      '• Large-scale Food Processors: Producing gari, fufu flour, or other cassava-based food products for wider distribution.\n'
      '• Animal Feed Manufacturers: For inclusion in livestock and poultry feed.\n'
      'Specific companies would vary by region (e.g., Ghana, Nigeria).',
  'can i sell cassava online?':
      'Selling fresh cassava roots directly online is challenging due to their short shelf life and bulkiness. However, you can effectively sell processed cassava products (like gari, fufu flour, or HQCF) online through e-commerce platforms, social media, or dedicated agricultural marketplaces, reaching a wider customer base beyond local markets.',

  // 13. Climate & Environment
  'can cassava grow in salty soil?':
      'While cassava is tolerant of many marginal soil conditions, it is generally sensitive to high salinity. Salty soils can inhibit growth and reduce yields significantly. It prefers well-drained, non-saline conditions. Extreme salinity will negatively impact its performance.',
  'does cassava need full sunlight?':
      'Yes, cassava needs full sunlight for optimal growth and root development. It is a sun-loving crop and requires at least 6-8 hours of direct sunlight daily. Shading can lead to leggy growth, reduced leaf area, and significantly lower root yields.',
  'how does climate change affect cassava?':
      'Climate change can affect cassava, though it is one of the most resilient crops. Impacts include:\n'
      '• Erratic Rainfall: More frequent droughts or intense rainfall affecting yields.\n'
      '• Temperature Changes: Altering optimal growing zones and potentially increasing pest/disease pressure.\n'
      '• Increased Pests/Diseases: Warmer temperatures can favor the spread and severity of certain pests (e.g., whiteflies) and diseases (e.g., CBSD). However, its inherent resilience also makes it a "climate-smart" crop for adaptation strategies.',
  'can cassava tolerate flooding?':
      'No, cassava has very poor tolerance to flooding or waterlogged conditions. Its roots are highly susceptible to rot in saturated soils, leading to plant death and significant yield losses. Good drainage is crucial.',
  'can i plant cassava near rivers?':
      'You can plant cassava near rivers, but with caution. Ensure the area has excellent drainage and is not prone to flooding or prolonged waterlogging. Riverbanks often have fertile soil, but proximity to water bodies increases the risk of waterlogging, which is detrimental to cassava. Also, consider any riparian buffer zone regulations.',

  // 14. Rotation & Companion Crops
  'can i rotate cassava with maize?':
      'Yes, rotating cassava with maize is a common and beneficial practice. Maize is a cereal crop that complements cassava well in a rotation system. It helps break pest and disease cycles specific to cassava, and can improve overall soil health and nutrient balance. Ensure proper fertilization for both crops.',
  ' good companion crops for cassava?':
      'Good companion crops for cassava often include:\n'
      '• Legumes: Cowpea, groundnuts (peanuts), beans, and soybeans. They fix nitrogen, improving soil fertility for cassava.\n'
      '• Cereals: Maize (corn) and sorghum, for diversified income and breaking pest cycles.\n'
      '• Vegetables: Some leafy greens or short-duration vegetables can be grown in the early stages before the cassava canopy closes.',
  'can cassava deplete soil nutrients?':
      'Yes, cassava can deplete soil nutrients, especially potassium, if grown continuously without nutrient replenishment. It is a heavy feeder, extracting significant amounts of nutrients from the soil. Long-term sustainable cultivation requires proper fertilization, crop rotation, and incorporation of organic matter to maintain soil fertility.',
  'how long should i wait before planting cassava again?':
      'If you\'re practicing crop rotation, it\'s generally recommended to wait at least 1-2 years before planting cassava again in the same plot after a cassava harvest. This allows for the break in pest and disease cycles and provides an opportunity to replenish soil nutrients with different crops.',
  'can i intercrop cassava and yam?':
      'Intercropping cassava and yam is sometimes practiced, but it can be challenging due to their differing growth habits and nutrient demands. Yam is a climbing vine, requiring support, while cassava is an upright shrub. Competition for light and nutrients can occur. Careful management of spacing and nutrient supply is crucial if attempted.',

  // 15. Training & Learning
  'are there training programs for cassava farmers?':
      'Yes, there are numerous training programs for cassava farmers, often offered by:\n'
      '• Government Agricultural Extension Services: At district or regional levels.\n'
      '• Agricultural Research Institutes: Like CSIR-CRI in Ghana or IITA.\n'
      '• NGOs and Development Organizations: Focused on rural development and food security.\n'
      '• Farmer Cooperatives: Often organize peer-to-peer learning sessions.',
  'can i learn cassava farming online?':
      'Yes, you can learn cassava farming online. Many agricultural organizations, universities, and research institutes offer online resources, guides, videos, and sometimes even free online courses on cassava cultivation, pest and disease management, and processing. YouTube channels by agricultural experts are also a good resource.',
  'are there mobile apps for cassava farming?':
      'Yes, there are mobile apps specifically developed for cassava farming, particularly for disease diagnosis (e.g., PlantVillage Nuru, which can detect CMD and CBSD using AI). Some apps also offer general farming advice, market information, or record-keeping tools relevant to cassava.',
  'can i talk to an agronomist about cassava?':
      'Yes, you can talk to an agronomist about cassava. Agronomists (or agricultural extension officers) are experts in crop production and can provide tailored advice on:\n'
      '• Variety selection\n'
      '• Soil management and fertilization\n'
      '• Pest and disease control\n'
      '• Best cultivation practices\n'
      'Contact your local Ministry of Food and Agriculture (MoFA) office in Ghana for extension services.',
  'where can i find cassava farming guides?':
      'You can find cassava farming guides from various sources:\n'
      '• Agricultural Research Institutes: Like CSIR-CRI (Ghana) or IITA (International Institute of Tropical Agriculture).\n'
      '• Government Agricultural Departments: Ministry of Food and Agriculture (MoFA) in Ghana.\n'
      '• Universities: Agricultural faculties.\n'
      '• NGOs: Involved in agricultural development.\n'
      '• Online Resources: Websites of the above organizations, agricultural blogs, and YouTube channels.',

  // 16. Research & Innovation
  'are there new varieties of disease-resistant cassava?':
      'Yes, significant research is ongoing, and new varieties of disease-resistant cassava are continuously being developed and released. Breeders focus on resistance to major diseases like Cassava Mosaic Disease (CMD) and Cassava Brown Streak Disease (CBSD), as well as improved yield and other desirable traits.',
  '’s the future of cassava farming?':
      'The future of cassava farming looks promising, driven by:\n'
      '• Climate Resilience: Its ability to thrive in changing climates.\n'
      '• Increased Demand: Growing demand for both food and industrial uses.\n'
      '• Biotechnology: Development of high-yielding, disease/pest-resistant, and biofortified varieties.\n'
      '• Mechanization: Increased use of machines for planting, weeding, and harvesting.\n'
      '• Value Addition: Expansion of processing into diverse, high-value products.',
  'can ai detect cassava diseases?':
      'Yes, Artificial Intelligence (AI) can detect cassava diseases. AI-powered mobile applications, such as PlantVillage Nuru, use image recognition and machine learning algorithms to analyze photos of cassava leaves and accurately identify common diseases like CMD and CBSD, providing farmers with quick and accessible diagnostic tools.',
  ' role does biotechnology play in cassava?':
      'Biotechnology plays a crucial role in cassava improvement, including:\n'
      '• Genetic Engineering: Developing genetically modified (GM) cassava with enhanced disease/pest resistance or nutritional content (e.g., biofortified Vitamin A cassava).\n'
      '• Marker-Assisted Selection (MAS): Accelerating conventional breeding by using DNA markers to select desirable traits.\n'
      '• Tissue Culture: Producing large quantities of disease-free planting material.\n'
      '• Genomics: Understanding the cassava genome to identify genes for important traits.',
  ' universities research cassava?':
      'Several universities globally and in Africa conduct significant research on cassava, often in collaboration with international research centers. Examples include:\n'
      '• University of Ghana, Legon (Ghana)\n'
      '• Kwame Nkrumah University of Science and Technology (KNUST, Ghana)\n'
      '• Cornell University (USA)\n'
      '• Makerere University (Uganda)\n'
      '• Federal University of Agriculture, Abeokuta (Nigeria)\n'
      'And many more, often working closely with research institutes like IITA and CIAT.',

  'can women benefit from cassava farming?':
      'Yes, women can significantly benefit from cassava farming. In many African countries, women are the primary cultivators, processors, and marketers of cassava. Investing in women farmers through training, access to inputs, and processing technologies can greatly enhance their livelihoods, food security, and economic empowerment.',
  'are there support groups for female cassava farmers?':
      'Yes, there are often support groups, cooperatives, and associations specifically for female cassava farmers. These groups provide platforms for sharing knowledge, accessing resources, pooling labor, and collectively marketing their produce, enhancing their collective bargaining power and economic resilience. Local NGOs and agricultural extension services can help you find them.',
  'how can youth get into cassava farming?':
      'Youth can get into cassava farming by:\n'
      '• Adopting modern practices: Using improved varieties and sustainable techniques.\n'
      '• Focusing on value addition: Processing cassava into higher-value products.\n'
      '• Leveraging technology: Using mobile apps for diagnosis, drones for monitoring, and social media for marketing.\n'
      '• Accessing training and mentorship: Through agricultural programs and experienced farmers.\n'
      '• Forming cooperatives: To access land, finance, and markets collectively.',
  'are there cooperatives for cassava growers?':
      'Yes, farmer cooperatives for cassava growers are common. These cooperatives help farmers by:\n'
      '• Bulk purchasing inputs: Getting better prices on fertilizers and planting material.\n'
      '• Collective marketing: Selling produce together to get better prices.\n'
      '• Accessing credit and training: As a unified group.\n'
      '• Sharing resources: Like machinery or processing equipment.\n'
      '• Advocacy: Representing farmers\' interests.',
  'can cassava farming reduce poverty?':
      'Yes, cassava farming can significantly reduce poverty. As a resilient staple crop that can grow on marginal lands, it provides food security for vulnerable populations. It also generates income for millions of smallholder farmers and creates employment opportunities throughout its value chain, from cultivation to processing and marketing.',

  // 18. Finance & Support
  'can i get a loan for cassava farming?':
      'Yes, you can often get a loan for cassava farming from various financial institutions, including:\n'
      '• Commercial banks: Some banks have specific agricultural loan products.\n'
      '• Microfinance institutions: Often target smallholder farmers.\n'
      '• Agricultural development banks: Institutions specifically established to support the agricultural sector.\n'
      '• Government programs: Some governments offer subsidized loans or grants for agricultural ventures. Loan eligibility criteria and requirements will vary.',
  'are there grants for cassava projects?':
      'Yes, there are often grants available for cassava projects, especially those focused on:\n'
      '• Research and development: For improved varieties or sustainable practices.\n'
      '• Value chain development: Supporting processing and marketing initiatives.\n'
      '• Climate change adaptation: Projects promoting resilient cassava farming.\n'
      '• Food security and poverty reduction: Initiatives in vulnerable communities.\n'
      'These grants are typically offered by international development organizations, foundations, and government agencies.',
  'how much does it cost to start a cassava farm?':
      'The cost to start a cassava farm varies widely depending on size, location, intensity of cultivation, and level of mechanization. Key cost components include:\n'
      '• Land preparation: Clearing, ploughing, ridging.\n'
      '• Planting material: Cost of stem cuttings.\n'
      '• Inputs: Fertilizers, pesticides (if used).\n'
      '• Labor: For planting, weeding, harvesting.\n'
      '• Tools/Equipment: Hoes, cutlasses, or larger machinery.\n'
      'For a smallholder in Ghana, it could range from a few hundred to a few thousand Ghana cedis per acre, while larger commercial farms would require significantly more capital.',
  'profit margin on cassava?':
      'The profit margin on cassava can be highly variable. It depends on factors like:\n'
      '• Yield per hectare: Higher yields generally mean higher profits.\n'
      '• Market prices: Fluctuations in prices for fresh roots or processed products.\n'
      '• Cost of production: Efficient management of inputs and labor.\n'
      '• Value addition: Processing cassava into higher-value products typically increases profit margins compared to selling raw roots.\n'
      'Good management practices and market access are key to maximizing profitability.',
  'are there microfinancing options for cassava farmers?':
      'Yes, microfinancing options are widely available for smallholder cassava farmers, especially in rural areas. Microfinance institutions (MFIs) provide small loans, savings, and other financial services to low-income individuals and groups who typically lack access to conventional banking services, enabling them to invest in their farms and improve their livelihoods.',

  // 19. Safety & Ethics
  'is cassava toxic?':
      'Yes, raw cassava contains naturally occurring cyanogenic glycosides, which can release toxic hydrogen cyanide when processed or ingested. This is why proper processing (peeling, grating, soaking, fermenting, drying, cooking) is essential to remove or reduce these toxins to safe levels before consumption.',
  'how do i remove toxins from cassava?':
      'Toxins (cyanide) are removed from cassava through various processing methods:\n'
      '• Peeling and grating: Breaks down cell walls, allowing enzymes to act.\n'
      '• Soaking: Submerging in water for extended periods (e.g., 2-3 days) to leach out toxins.\n'
      '• Fermentation: Microorganisms break down glycosides (e.g., for gari, fufu).\n'
      '• Drying: Sun-drying or oven-drying reduces moisture and allows cyanide to volatilize.\n'
      '• Cooking: Boiling or frying further reduces residual cyanide. Combining methods (e.g., grating, fermenting, then frying for gari) is highly effective.',
  'can i feed raw cassava to animals?':
      'No, you should not feed raw cassava directly to animals. Like humans, animals are susceptible to cyanide poisoning from raw cassava. Cassava intended for animal feed must be properly processed (e.g., chipped and thoroughly dried, or fermented) to reduce its cyanogenic content to safe levels.',
  ' happens if humans eat raw cassava?':
      'If humans eat raw cassava, especially bitter varieties, they risk acute cyanide poisoning. Symptoms can appear quickly and include nausea, vomiting, abdominal pain, headache, dizziness, weakness, and difficulty breathing. In severe cases, it can lead to convulsions, coma, and even death. Chronic consumption of improperly processed cassava can lead to neurological disorders like Konzo.',
  'is all cassava safe to eat?':
      'Not all cassava is safe to eat in its raw form or with minimal processing. Cassava varieties are categorized as "sweet" (low cyanide) or "bitter" (high cyanide). While sweet varieties can be eaten after simple cooking (like boiling), bitter varieties must undergo extensive processing (like prolonged soaking, fermentation, and drying) to remove dangerous levels of cyanide before they are safe for consumption.',

  // 20. Tools & Technology
  ' farm tools do i need for cassava?':
      'Basic farm tools needed for cassava include:\n'
      '• Cutlass/Machete: For land clearing and harvesting stems.\n'
      '• Hoe: For land preparation, weeding, and mounding/ridging.\n'
      '• Spade/Digging Stick: For harvesting roots.\n'
      '• Wheelbarrow/Head Pan: For transporting harvested roots or inputs.\n'
      'For larger farms, tractors with ploughs, harrows, and ridgers, and potentially mechanical planters or harvesters, would be needed.',
  'are there machines for cassava harvesting?':
      'Yes, there are machines for cassava harvesting. These range from tractor-mounted diggers that loosen the soil and lift roots to more specialized, self-propelled cassava harvesters. While effective for large-scale commercial farms, they are still less common for smallholder farmers due to cost and suitability for varied terrain.',
  'can i plant cassava with a tractor?':
      'Yes, you can plant cassava with a tractor, especially on larger, well-prepared fields. Tractor-mounted planters can efficiently create ridges and plant stem cuttings, significantly reducing labor and time compared to manual planting. This is a common practice in commercial cassava farming.',
  'are there mobile apps for disease diagnosis?':
      'Yes, as mentioned, there are mobile apps specifically for cassava disease diagnosis. A notable example is PlantVillage Nuru, developed by Penn State University and partners, which uses artificial intelligence to identify Cassava Mosaic Disease and Cassava Brown Streak Disease from photos of leaves, providing real-time feedback to farmers.',
  'can drones help in cassava farming?':
      'Yes, drones can help in cassava farming, particularly in larger or commercial operations, by:\n'
      '• Mapping and monitoring: Providing aerial views of farm health, stand establishment, and problem areas.\n'
      '• Disease/Pest detection: Identifying stressed plants or disease outbreaks early.\n'
      '• Precision agriculture: Guiding targeted application of fertilizers or pesticides.\n'
      '• Yield estimation: Using imagery to predict harvest volumes.',

  // 21. Monitoring & Record-Keeping
  'how do i track cassava yields?':
      'To track cassava yields:\n'
      '1. Measure plot size: Accurately determine the area harvested.\n'
      '2. Weigh harvest: Weigh the fresh roots harvested from that measured plot.\n'
      '3. Calculate: Convert the weight to tonnes per hectare (1 hectare = 10,000 square meters) by scaling up your measured plot yield. Keep records for each harvest and plot.',
  ' records should i keep?':
      'For effective farm management, you should keep records of:\n'
      '• Planting details: Date, variety, spacing, planting material source.\n'
      '• Inputs: Fertilizer type, amount, application date; pesticide type, amount, date.\n'
      '• Labor: Hours worked, tasks performed, cost.\n'
      '• Harvest details: Date, yield (weight), plot harvested.\n'
      '• Pest/Disease observations: Dates, symptoms, management actions taken.\n'
      '• Rainfall/Irrigation: Records of water received/applied.\n'
      '• Sales: Dates, quantity sold, price received.',
  'how can i calculate cost per acre?':
      'To calculate the cost per acre (or per hectare):\n'
      '1. Sum all expenses: Add up all costs incurred for that specific acre/hectare (land prep, planting material, fertilizer, labor, pest control, etc.).\n'
      '2. Divide by area: Divide the total expenses by the acreage/hectare to get the cost per unit area.\n'
      'This helps you understand profitability and make informed decisions.',
  'can i use excel or apps for tracking?':
      'Yes, absolutely! Using Excel spreadsheets or dedicated farm management apps is highly recommended for tracking cassava farming data. They allow for organized data entry, easy calculations, and visual representation of trends, helping you analyze performance, costs, and profitability more effectively than manual record-keeping.',
  'should i use gps for mapping cassava plots?':
      'Using GPS for mapping cassava plots is highly beneficial, especially for larger or commercial farms. It allows you to:\n'
      '• Accurately define boundaries: Precisely measure plot sizes.\n'
      '• Plan field operations: Optimize planting patterns and irrigation.\n'
      '• Monitor spatial variations: Identify areas with different yields or problems.\n'
      '• Record data: Link field data to specific geographical locations for better analysis and decision-making.',

  // 22. Business & Strategy
  'can i turn cassava farming into a business?':
      'Yes, you can definitely turn cassava farming into a profitable business. It requires a strategic approach focusing on:\n'
      '• Commercial varieties: Planting high-yielding varieties.\n'
      '• Good agricultural practices: Maximizing yield and quality.\n'
      '• Value addition: Processing roots into gari, flour, or starch to increase income.\n'
      '• Market linkages: Securing reliable buyers for your produce.\n'
      '• Business planning: Managing costs, finances, and marketing effectively.',
  'how much land do i need for profit?':
      'The amount of land needed for profit from cassava farming depends on your target income, expected yield, and market prices. While small plots can provide supplementary income, for a significant commercial profit, you\'d generally need at least 1-5 hectares (2.5-12.5 acres) or more, coupled with efficient management and potential value addition.',
  ' risks in cassava business?':
      'Risks in the cassava business include:\n'
      '• Pests and Diseases: Outbreaks can devastate yields.\n'
      '• Market Price Fluctuations: Unpredictable prices for raw roots.\n'
      '• Post-Harvest Losses: Rapid perishability of fresh roots.\n'
      '• Climate Risks: Droughts or excessive rainfall.\n'
      '• Labor Costs: Manual operations can be expensive.\n'
      '• Access to Finance: Difficulty in securing capital for expansion or processing.',
  'can i start a cassava processing factory?':
      'Yes, you can start a cassava processing factory, but it requires substantial capital investment, technical expertise, and a guaranteed supply of raw cassava roots. Factories can produce products like gari, fufu flour, industrial starch, or even bioethanol, offering significant value addition and market opportunities.',
  'should i register a cassava brand?':
      'If you are producing and selling processed cassava products (e.g., packaged gari, HQCF, cassava snacks) beyond local, informal markets, then yes, registering a cassava brand is a good business strategy. It helps in:\n'
      '• Product differentiation: Standing out from competitors.\n'
      '• Building trust: Signifying quality and consistency.\n'
      '• Marketing and promotion: Creating a recognizable identity.\n'
      '• Legal protection: Preventing others from using your brand name.',

  // 23. Sustainability & Organic Farming
  'can i grow cassava organically?':
      'Yes, you can grow cassava organically. Organic cassava farming focuses on natural methods for soil fertility, pest, and weed management, avoiding synthetic fertilizers and pesticides. It relies on practices like:\n'
      '• Crop rotation with legumes.\n'
      '• Use of compost and organic manure.\n'
      '• Manual weeding and mulching.\n'
      '• Use of naturally resistant varieties and biological pest control.',
  ' eco-friendly methods of disease control?':
      'Eco-friendly methods of disease control for cassava include:\n'
      '• Using disease-resistant varieties: This is the most effective and sustainable method.\n'
      '• Sanitation: Removing and destroying infected plants promptly.\n'
      '• Crop rotation: To break disease cycles.\n'
      '• Healthy soil: Promoting plant vigor through organic matter and balanced nutrients.\n'
      '• Biological control: Encouraging natural enemies of vectors like whiteflies.',
  'does cassava farming contribute to sustainability?':
      'Cassava farming can contribute to sustainability when practiced responsibly. Its resilience, ability to grow on marginal lands, and role in food security are sustainable aspects. However, monoculture without nutrient replenishment or unsustainable land clearing can be detrimental. Sustainable practices like intercropping, agroforestry, and integrated nutrient management enhance its sustainability.',
  'how do i farm cassava without chemicals?':
      'To farm cassava without chemicals:\n'
      '• Choose resistant varieties: Select varieties naturally resistant to local pests and diseases.\n'
      '• Build soil health: Rely on compost, manure, and cover crops for fertility.\n'
      '• Practice crop rotation: To manage soil-borne pests and diseases.\n'
      '• Weed manually/mulch: Control weeds without herbicides.\n'
      '• Encourage beneficial insects: For natural pest control.\n'
      '• Use clean planting material: To prevent disease introduction.',
  'can cassava farming regenerate degraded land?':
      'Yes, cassava farming, particularly when integrated with sustainable practices, can play a role in regenerating degraded land. Its deep root system can help improve soil structure and prevent erosion. When combined with organic matter addition, cover cropping, and minimal tillage, it can help rehabilitate nutrient-depleted or eroded soils over time.',

  // 24. Troubleshooting
  'why is my cassava growing slowly?':
      'Slow cassava growth can be due to:\n'
      '• Poor soil fertility: Lack of essential nutrients, especially N and K.\n'
      '• Inadequate water: Drought stress.\n'
      '• Pest or disease infestation: Such as mealybugs, green mites, or viral diseases.\n'
      '• Poor planting material: Weak or unhealthy stem cuttings.\n'
      '• Weed competition: Weeds outcompeting young cassava plants.\n'
      '• Shading: Insufficient sunlight.',
  'why are my cassava leaves yellowing?':
      'Cassava leaves can yellow for several reasons:\n'
      '• Nutrient deficiency: Most commonly nitrogen (general yellowing of older leaves) or potassium (yellowing/scorching of leaf margins).\n'
      '• Drought stress: Leaves may turn yellow and wilt during prolonged dry periods.\n'
      '• Pest infestation: Green mites cause yellow mottling.\n'
      '• Disease: Cassava Mosaic Disease causes yellow mosaic patterns.\n'
      '• Aging: Natural yellowing and shedding of older leaves.',
  'why are cassava stems rotting?':
      'Cassava stems can rot due to:\n'
      '• Excessive moisture/Waterlogging: The most common cause, especially in poorly drained soils.\n'
      '• Fungal or bacterial infections: Specific pathogens can cause stem rot.\n'
      '• Damaged planting material: Rot can start from bruised or diseased cuttings.\n'
      '• High humidity and poor air circulation: Creating favorable conditions for pathogens.\n'
      '• Pest damage: Stem borers can create entry points for rot organisms.',
  'why is my yield lower than expected?':
      'Lower than expected cassava yield can be attributed to:\n'
      '• Poor variety selection: Using low-yielding or unsuitable varieties.\n'
      '• Pest and disease outbreaks: Uncontrolled infestations.\n'
      '• Poor soil fertility: Insufficient nutrients.\n'
      '• Inadequate rainfall/irrigation: Water stress during critical growth stages.\n'
      '• Suboptimal spacing: Too wide or too dense.\n'
      '• Poor weed control: Competition reducing resources for cassava.\n'
      '• Poor planting material: Unhealthy or damaged cuttings.',
  'why are cassava roots thin?':
      'Cassava roots may be thin due to:\n'
      '• Insufficient potassium (K): Potassium is crucial for root bulking and starch accumulation.\n'
      '• Early harvest: Roots not given enough time to mature and swell.\n'
      '• Poor soil compaction/hardpan: Restricting root expansion.\n'
      '• Severe pest or disease pressure: Stressing the plant and diverting energy from root development.\n'
      '• Genetic factors: Some varieties naturally produce thinner roots.',

  // 25. Community & Help
  'where can i meet other cassava farmers?':
      'You can meet other cassava farmers at:\n'
      '• Local farmer cooperative meetings.\n'
      '• Agricultural extension office events or field days.\n'
      '• Local markets where cassava is sold.\n'
      '• Community gatherings or forums focused on agriculture.\n'
      '• Agricultural fairs and exhibitions.',
  'are there sapp groups for cassava farmers?':
      'Yes, it is common for agricultural extension officers, NGOs, or farmer associations to set up sApp groups for cassava farmers. These groups facilitate quick information sharing, problem-solving, market updates, and peer-to-peer support. You can inquire about such groups at your local agricultural office.',
  'is there government support for cassava?':
      'Yes, in many cassava-producing countries like Ghana, there is government support for the cassava sector. This often includes:\n'
      '• Extension services and training.\n'
      '• Promotion and distribution of improved varieties.\n'
      '• Subsidies on inputs (e.g., fertilizer).\n'
      '• Programs for value chain development and processing.\n'
      '• Research funding.\n'
      '• Policies aimed at boosting production and utilization (e.g., "Planting for Food and Jobs" in Ghana).',
  'can i get extension services in my region?':
      'Yes, you can get agricultural extension services in your region (Sunyani, Bono Region, Ghana). The Ministry of Food and Agriculture (MoFA) operates district and regional agricultural offices with extension officers who provide advice, training, and support to farmers on various crops, including cassava. Visit your nearest MoFA office.',
  'where can i report cassava disease outbreaks?':
      'You should report cassava disease outbreaks to your local:\n'
      '• Agricultural Extension Officer (MoFA in Ghana).\n'
      '• District or Regional Agricultural Department.\n'
      '• Nearest agricultural research institute (e.g., CSIR-CRI in Ghana).\n'
      'Early reporting helps in rapid response, containment, and prevents wider spread of diseases.',

  // 26. General Curiosity
  'who introduced cassava to africa?':
      'Cassava was introduced to Africa by Portuguese traders in the 16th century from its origin in South America (specifically the Amazon basin). It quickly spread across the continent due to its adaptability and high yield, becoming a staple crop in many African countries.',
  'is cassava a tuber or a root?':
      'Cassava is technically a root crop, specifically a storage root. While often mistakenly called a tuber, tubers (like potatoes) are swollen underground stems, whereas cassava\'s edible part develops from swollen adventitious roots.',
  'can cassava grow in containers?':
      'Yes, cassava can be grown in containers, though it typically won\'t reach the same size or yield as field-grown plants. For container growing, use large pots (at least 15-20 gallons or 60-80 liters) with good drainage, well-draining potting mix, and ensure adequate sunlight, water, and nutrients.',
  'is cassava affected by climate change?':
      'Yes, cassava is affected by climate change, though it is one of the most resilient crops. While it tolerates drought, increased frequency of extreme weather events (prolonged droughts, intense floods) and changes in temperature can impact yields. Climate change also influences the spread and severity of pests (like whiteflies) and diseases (like CBSD), which are major threats to cassava.',
  ' country grows the most cassava?':
      'Nigeria is the country that grows the most cassava globally, producing significantly more than any other nation. Other major producers include Democratic Republic of Congo, Thailand, Indonesia, Brazil, and Angola.',

  // Funny & Silly Cassava Questions
  'is cassava secretly running the world economy?':
      'While cassava is a major player in the economies of many tropical countries and a vital food security crop, it\'s not *secretly* pulling all the strings. Its economic impact is quite openly celebrated, especially as demand for its diverse products grows!',
  'can i marry someone who doesn’t like cassava?':
      'Of course you can! Love knows no bounds, even if one of you prefers potatoes. Just make sure there\'s enough cassava for you, and perhaps they can appreciate your passion for this amazing root.',
  'if i dream of cassava, does that mean i’m a farmer?':
      'Not necessarily, but it might mean you\'re thinking a lot about food, sustainability, or perhaps you\'ve just had a delicious fufu meal recently! Or, maybe, just maybe, it\'s the universe telling you to consider a career in agriculture.',
  'can cassava be my emotional support root?':
      'Absolutely! While it might not offer cuddles, the sheer joy of a thriving cassava plant, the satisfaction of a good harvest, and the delicious meals it provides can certainly be emotionally uplifting. It\'s a silent, starchy companion.',
  'is there cassava perfume? (smell like success 🍠)':
      'As far as we know, cassava perfume isn\'t a thing yet. Its natural aroma might be a bit too starchy for a typical fragrance! But if "smelling like success" means smelling like a bountiful harvest and economic growth, then perhaps the idea isn\'t so silly after all!',
  'can i charge my phone with cassava power? 🔋':
      'Theoretically, yes, but it\'s not practical for everyday use. You can extract ethanol from cassava, and ethanol can be used to generate electricity, but directly plugging your phone into a cassava root won\'t work. It\'s a multi-step process!',
  ' if my cassava grows legs and runs away?':
      'If your cassava grows legs and runs away, you\'ve either discovered a new species, or you\'re experiencing a very vivid dream! Cassava roots are firmly planted in the ground, so you\'re safe from any root-related escapes.',
  'is “cassava coin” the next cryptocurrency?':
      '"Cassava Coin" has a nice ring to it! While it\'s not a cryptocurrency yet, the idea of a digital currency backed by a stable, high-demand agricultural commodity like cassava isn\'t entirely far-fetched in the world of blockchain. Maybe you\'ve just invented something!',
  'can cassava go to space? 🚀':
      'Cassava has not yet made it to space. However, its hardiness and ability to produce high calories make it an interesting candidate for potential space agriculture research. Who knows, future astronauts might be enjoying fufu on Mars!',
  'if cassava had a theme song,  would it be?':
      'It would definitely be something strong, resilient, and perhaps a little understated, given its quiet power. Maybe "I Will Survive" by Gloria Gaynor, given its incredible drought tolerance, or a catchy, upbeat tune about feeding the world!',
  'is cassava gluten-free or just shy?':
      'Cassava is naturally gluten-free! It\'s not shy about it; it\'s just a root that doesn\'t contain the gluten proteins found in wheat, barley, and rye, making it an excellent alternative for those with gluten sensitivities.',
  'can i make cassava juice and call it “root beer”?':
      'You can certainly make a juice from cassava, but it wouldn\'t be "root beer" in the traditional sense, which is a fermented, carbonated beverage. Cassava juice would be starchy and need significant processing to be palatable and safe (due to the cyanide). But you can get creative with branding!',
  'is cassava a fruit in disguise?':
      'No, cassava is definitively a root, specifically a tuberous root, not a fruit. Fruits develop from the flower\'s ovary and contain seeds (like mangoes or oranges). Cassava is all about that delicious underground starch.',
  '’s the cassava zodiac sign? (root-arius?)':
      'If cassava had a zodiac sign, it would likely be something earthy and resilient, perhaps a "Tuber-us" (Taurus) for its steadfastness and productivity, or indeed a "Root-arius" (Sagittarius) for its widespread global presence!',
  'if cassava had a university, would it offer rootology 101?':
      'Absolutely! "Rootology 101" would be a foundational course, covering everything from soil science for roots to advanced root-bulking techniques and the complex biochemistry of starch formation. Other courses might include "Stem Cell Biology" or "The Art of Fermentation."',
  'how do i know if my cassava plant is healthy?':
      'You can tell if your cassava plant is healthy by observing vigorous growth, dark green leaves, strong upright stems, good branching, and the absence of visible pests or disease symptoms. A healthy plant will also be free from stunted growth or unusual discoloration.',
  ' early signs of disease in cassava?':
      'Early signs of disease in cassava vary but often include:\n'
      '• Unusual leaf discoloration: Yellowing, mottling, or mosaic patterns.\n'
      '• Leaf distortion: Curling, crumpling, or abnormal shapes.\n'
      '• Stunted growth: Plants not growing as vigorously as others.\n'
      '• Wilting or drooping leaves without obvious water stress.\n'
      '• Small spots or lesions on leaves or stems.',
  'how often should i check my cassava leaves?':
      'It\'s advisable to check your cassava leaves and plants regularly, ideally at least once a week. Frequent scouting allows for early detection of pests or diseases, enabling timely intervention and preventing widespread damage.',
  'can overwatering cause cassava leaf problems?':
      'Yes, overwatering can cause significant problems for cassava leaves and the entire plant. Saturated soils lead to root rot, which impairs nutrient and water uptake. This can manifest as yellowing, wilting, and drooping leaves, even if the soil itself is wet, because the roots are unable to function properly.',
  ' nutrients are essential for cassava health?':
      'The most essential nutrients for cassava health are Potassium (K), Nitrogen (N), and Phosphorus (P). Potassium is particularly crucial for root bulking and starch accumulation. Micronutrients like zinc and boron are also important for overall plant health, though needed in smaller quantities.',
  'how does soil type affect cassava health?':
      'Soil type significantly affects cassava health:\n'
      '• Well-drained, loamy soils are ideal, promoting healthy root development and preventing waterlogging.\n'
      '• Heavy clay soils can lead to waterlogging and root rot, hindering growth.\n'
      '• Sandy soils may drain too quickly, requiring more frequent watering and nutrient management due to leaching.\n'
      '• Soil pH: Cassava tolerates a wide range but prefers slightly acidic to neutral soils (pH 5.5-7.0).',
  'best fertilizer for cassava?':
      'The best fertilizer for cassava is a balanced NPK (Nitrogen, Phosphorus, Potassium) blend, with a high emphasis on Potassium (K). Soil test results should guide specific fertilizer recommendations. Organic manures and compost are also excellent for improving soil health and providing nutrients.',
  'why are my cassava leaves turning yellow?':
      'Cassava leaves can turn yellow due to:\n'
      '• Nutrient deficiency: Especially nitrogen (general yellowing of older leaves) or potassium (yellowing/scorching of leaf margins).\n'
      '• Drought stress: During prolonged dry periods.\n'
      '• Pest infestation: Like cassava green mites.\n'
      '• Disease: Viral diseases like Cassava Mosaic Disease (CMD) cause yellow mosaic patterns.\n'
      '• Overwatering/Root Rot: Leading to impaired nutrient uptake.\n'
      '• Natural aging: Older leaves naturally yellow and drop.',
  'how can i prevent cassava diseases?':
      'To prevent cassava diseases:\n'
      '• Use disease-resistant varieties: This is the most effective method.\n'
      '• Plant healthy cuttings: Always use disease-free planting material.\n'
      '• Rogueing: Promptly remove and destroy infected plants.\n'
      '• Good field hygiene: Control weeds, manage vectors (e.g., whiteflies).\n'
      '• Crop rotation: Break disease cycles.\n'
      '• Maintain soil health: Ensure balanced nutrition for strong plants.',
  'how important is spacing for healthy cassava?':
      'Spacing is highly important for healthy cassava. Proper spacing (e.g., 1m x 1m) ensures:\n'
      '• Adequate sunlight: Preventing etiolation (stretching for light).\n'
      '• Sufficient nutrients and water: Reducing competition between plants.\n'
      '• Good air circulation: Reducing humidity and fungal disease risk.\n'
      '• Optimal root development: Allowing roots to expand without overcrowding.\n'
      '• Easier farm operations: For weeding, fertilizing, and harvesting.',

  // Cassava Mosaic Disease (CMD)
  ' causes cassava mosaic disease?':
      'Cassava Mosaic Disease (CMD) is caused by a group of related geminiviruses, primarily the African Cassava Mosaic Virus (ACMV) and the East African Cassava Mosaic Virus (EACMV). These viruses are transmitted by whiteflies and infected planting material.',
  'how do i identify mosaic symptoms?':
      'You can identify mosaic symptoms by looking for:\n'
      '• Distinct yellow or pale green patches alternating with normal green areas on the leaves, creating a characteristic mosaic pattern.\n'
      '• Leaf distortion: Leaves may be crumpled, twisted, or unusually small.\n'
      '• General stunting of the plant, with reduced leaf size and overall vigor in severely infected cases.',
  'can cmd be cured after infection?':
      'No, CMD cannot be cured after a cassava plant is infected. Once a plant is infected with the virus, it remains infected. The best approach is prevention, using resistant varieties, and immediately removing and destroying infected plants to prevent further spread.',
  'is cmd viral or bacterial?':
      'CMD (Cassava Mosaic Disease) is viral. It is caused by specific geminiviruses.',
  'cmd spread?':
      'CMD is primarily spread in two ways:\n'
      '1. Through infected planting material: Using stem cuttings from an infected plant will result in diseased new plants.\n'
      '2. By whiteflies (Bemisia tabaci): These tiny insects act as vectors, acquiring the virus from infected plants and transmitting it to healthy ones as they feed.',
  ' cmd-resistant varieties?':
      'CMD-resistant varieties are specific cassava cultivars that have been bred or selected for their ability to resist or tolerate infection by the Cassava Mosaic Virus. These varieties may show no symptoms, or very mild symptoms, even when exposed to the virus, and often maintain good yields. Examples include TME 419 and TMS 30572, among others.',
  'can cmd reduce cassava yield?':
      'Yes, CMD can significantly reduce cassava yield, sometimes by 30-80% or even lead to total crop loss in severe infections with susceptible varieties. Infected plants produce fewer and smaller roots, which can also be woody and unpalatable.',
  'are whiteflies responsible for cmd?':
      'Yes, whiteflies (specifically *Bemisia tabaci*) are responsible for the secondary spread of CMD from infected plants to healthy ones in the field. They are the primary biological vectors of the geminiviruses that cause the disease.',
  ' does a mosaic-infected cassava leaf look like?':
      'A mosaic-infected cassava leaf typically shows a distinct pattern of yellow or light green areas interspersed with normal dark green areas, resembling a mosaic. The leaves are often distorted, crinkled, or reduced in size, especially the younger leaves.',
  'how can i control whiteflies in cassava?':
      'Controlling whiteflies in cassava involves:\n'
      '• Using CMD-resistant varieties: This reduces the source of the virus.\n'
      '• Rogueing: Removing infected plants reduces the virus reservoir for whiteflies.\n'
      '• Biological control: Encouraging natural predators of whiteflies.\n'
      '• Insecticides: Can be used, but are often not effective or sustainable for whitefly control in the long term, and can harm beneficial insects.',

  // Cassava Brown Streak Disease (CBSD)
  ' cassava brown streak disease?':
      'Cassava Brown Streak Disease (CBSD) is a severe viral disease of cassava that primarily affects the storage roots, causing a characteristic brown, necrotic streaking. It also causes leaf and stem symptoms, but the root damage is  makes it so devastating.',
  ' causes brown streak in cassava roots?':
      'Brown streak in cassava roots is caused by viruses, specifically the Ugandan Cassava Brown Streak Virus (UCBSV) and the Cassava Brown Streak Virus (CBSV). These viruses cause necrosis (tissue death) within the root, leading to the characteristic brown streaks and hardening.',
  'can cbsd affect cassava leaves too?':
      'Yes, CBSD can affect cassava leaves, though the root symptoms are often more economically damaging. Leaf symptoms typically appear as yellow or brownish streaking along the veins, sometimes causing distortion. These symptoms can be subtle, especially in some varieties.',
  'how do i test if my cassava has cbsd?':
      'Testing for CBSD involves:\n'
      '• Visual inspection: Looking for characteristic leaf (vein streaking) and stem (lesions) symptoms.\n'
      '• Cutting roots: Slicing open roots to check for the internal brown, necrotic streaks. This is the definitive visual test.\n'
      '• Laboratory testing: For confirmation, molecular tests (e.g., PCR) can detect the virus in plant tissues.',
  ' regions are most affected by cbsd?':
      'CBSD is most prevalent and devastating in East Africa, particularly countries like Uganda, Tanzania, Kenya, Rwanda, Burundi, and parts of DR Congo. It has also been detected in parts of Central Africa and is a growing concern in West Africa.',
  'are symptoms visible early in cbsd?':
      'CBSD symptoms, especially on leaves, can sometimes be subtle or only appear later in the plant\'s growth cycle, making early detection challenging. Root symptoms become prominent as the roots mature. This latency can make it difficult to identify infected planting material early on.',
  'can cbsd be spread through cuttings?':
      'Yes, CBSD is primarily spread through infected stem cuttings. Using cuttings from a CBSD-infected mother plant is the most common way the disease is disseminated, leading to diseased plants in new fields. It is also spread by whiteflies.',
  'how do i dispose of cbsd-infected plants?':
      'To dispose of CBSD-infected plants, you should:\n'
      '• Uproot the entire plant, including roots and stems.\n'
      '• Burn the infected plant material on site or bury it deeply away from other cassava fields.\n'
      '• Do not use any part of the infected plant for propagation or consumption.\n'
      '• Clean tools after working with infected plants to prevent mechanical spread.',
  'can cbsd destroy my entire harvest?':
      'Yes, CBSD has the potential to destroy an entire cassava harvest, especially if susceptible varieties are planted and the disease is widespread. The internal necrosis in the roots makes them inedible, leading to complete economic loss for farmers.',
  'are there any resistant cassava varieties?':
      'Yes, significant research efforts have led to the development of CBSD-resistant cassava varieties. Breeding programs focus on identifying and introducing genes that confer resistance or tolerance to the CBSD viruses, providing farmers with a crucial tool to combat the disease.',

  // Cassava Bacterial Blight (CBB)
  ' cassava bacterial blight?':
      'Cassava Bacterial Blight (CBB) is a serious bacterial disease of cassava caused by the bacterium *Xanthomonas axonopodis pv. manihotis*. It affects leaves, stems, and can cause significant yield losses.',
  ' causes cbb in cassava?':
      'CBB in cassava is caused by the bacterium Xanthomonas axonopodis pv. manihotis. This bacterium enters the plant through natural openings (stomata) or wounds.',
  'are leaf spots a sign of blight?':
      'Yes, angular water-soaked leaf spots that later turn brown and necrotic are a primary sign of Cassava Bacterial Blight (CBB). These spots often appear along leaf veins and can merge to form larger blighted areas.',
  'bacterial blight transmitted?':
      'Bacterial blight is primarily transmitted through:\n'
      '• Infected planting material (cuttings).\n'
      '• Rain splash: Rain droplets can carry bacteria from infected plants to healthy ones.\n'
      '• Wind-blown rain.\n'
      '• Contaminated tools (e.g., machetes, hoes) during farming operations.\n'
      '• Infected crop residues left in the field.',
  'can rain spread blight?':
      'Yes, rain can effectively spread bacterial blight. Rain splash carries the bacteria from infected leaves or plant debris to healthy plant parts, facilitating rapid dissemination of the disease within a field, especially during heavy rains.',
  '’s the best way to control cbb?':
      'The best ways to control CBB are through an integrated approach:\n'
      '• Using resistant varieties: Plant CBB-resistant cassava cultivars.\n'
      '• Disease-free planting material: Use only healthy cuttings.\n'
      '• Field hygiene: Remove and destroy infected plants and residues.\n'
      '• Crop rotation: To break the disease cycle.\n'
      '• Avoid mechanical damage: Minimize wounds during weeding or other operations.\n'
      '• Tool sanitation: Disinfect farm tools regularly.',
  'can pruning infected parts help?':
      'Yes, pruning infected parts can help control CBB, especially if the infection is localized. Carefully cut off affected leaves, petioles, and stems, ensuring you prune well below the visible symptoms. Remember to disinfect your pruning tools after each cut to avoid spreading the bacteria.',
  ' chemicals can treat cbb?':
      'While some copper-based bactericides might be used to manage CBB, chemical control is generally less effective and not economically viable for smallholder cassava farmers. Prevention and cultural control methods are typically preferred. Always consult with an agricultural expert before using any chemicals.',
  'can poor hygiene cause bacterial blight?':
      'Yes, poor hygiene can significantly contribute to the spread of bacterial blight. Using contaminated tools (e.g., pruning shears, machetes) or leaving infected plant debris in the field allows the bacteria to persist and readily infect new plants, especially during wet conditions.',
  'is cbb more common in wet seasons?':
      'Yes, CBB is generally more common and severe in wet seasons. The bacterium thrives in humid conditions, and rain splash is a primary mechanism for its spread, making the disease more prevalent and aggressive during periods of high rainfall and humidity.',

  // Cassava Green Mite (CGM) Infestation
  ' cassava green mite?':
      'The Cassava Green Mite (CGM), *Mononychellus tanajoa*, is a tiny, polyphagous spider mite that is a major pest of cassava. It feeds on the underside of young leaves, sucking sap and causing significant damage, especially during dry seasons.',
  ' do cgms look like on the leaf?':
      'CGMs are tiny, almost microscopic, and difficult to see with the naked eye. On the leaf, they appear as minute, greenish or yellowish specs, often concentrated on the underside of young leaves. You might need a hand lens to clearly see them. Their presence is usually indicated by the damage they cause.',
  'do green mites cause leaf curling?':
      'Yes, severe infestations of cassava green mites cause characteristic leaf damage including leaf curling, distortion, and puckering, especially on the young, developing leaves. The leaves may also appear yellow or silvery on the affected areas.',
  'can i see cgm with my naked eye?':
      'It is very difficult to see individual CGMs with the naked eye due to their extremely small size (less than 0.5 mm). You can sometimes see them as tiny moving specks on the underside of leaves or detect their presence by the damage they cause, but a hand lens (magnifying glass) is usually needed for clear observation.',
  'how fast do cgms reproduce?':
      'CGMs reproduce very rapidly, especially under warm, dry conditions. Their life cycle from egg to adult can be completed in as little as 7-10 days, allowing for multiple generations to build up quickly within a short period, leading to rapid population explosions.',
  'can neem oil control green mites?':
      'Yes, neem oil can be effective in controlling cassava green mites, especially for mild to moderate infestations or as part of an organic pest management strategy. Neem oil acts as an antifeedant, repellent, and growth disruptor, reducing mite populations. It needs to be applied thoroughly, covering both sides of the leaves.',
  'are natural predators effective?':
      'Yes, natural predators are very effective in controlling cassava green mites. Predatory mites (e.g., *Phytoseiulus* species), ladybird beetles, and other generalist predators feed on CGMs. Conserving and introducing these natural enemies is a key biological control strategy.',
  'how much damage can cgms cause?':
      'CGMs can cause significant damage to cassava, leading to substantial yield losses of 30-80% or more in severe infestations, particularly during dry seasons. They cause defoliation, stunted plant growth, reduced photosynthetic capacity, and ultimately, greatly reduced root size and quality.',
  ' weather conditions encourage cgm?':
      'Warm and dry weather conditions highly encourage the proliferation of cassava green mites. Low humidity and high temperatures favor their rapid reproduction and dispersal, making them a more serious pest during the dry season.',
  'can i use biocontrol for cassava mites?':
      'Yes, biocontrol is a highly recommended and effective strategy for managing cassava mites. The most common biocontrol involves the release or encouragement of predatory mites, such as *Typhlodromalus manihoti* (formerly *Neoseiulus idaeus*), which specifically prey on cassava green mites. This is a sustainable and environmentally friendly approach.',
  'thank you': 'You\'re welcome! Feel free to ask any other questions about cassava cultivation.',
  'thanks': 'You\'re welcome! Let me know if you need more information.',
  'ok': 'Is there anything else you\'d like to know about cassava farming?',


    // ... (Continue adding more entries aiming for diversity and detail)
  };

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _loadChatHistory();
  }

  Future<void> _initializeChat() async {
    try {
      const apiKey = 'AIzaSyBUFaKOMcSxHOXUsl-mkyl1bdIJqfpIXRs';
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );

      _chat = _model.startChat(
        history: [
          Content.text(
            "You are CassavaCareBot, an expert agronomist specializing in cassava leaf health. "
            "Focus on providing advice about: \n"
            "1. Identifying cassava diseases from symptoms\n"
            "2. Best practices for cassava cultivation\n"
            "3. Disease prevention and treatment methods\n"
            "Keep responses clear and practical for farmers.",
          ),
        ],
      );

      // Reset retry attempts on successful initialization
      _retryAttempts = 0;
    } catch (e) {
      print('Chat initialization error: $e');
      if (_retryAttempts < _maxRetries) {
        _retryAttempts++;
        _showError(
            'Connection failed. Retrying... (Attempt $_retryAttempts of $_maxRetries)');
        await Future.delayed(Duration(seconds: _retryAttempts * 2));
        await _initializeChat();
      } else {
        _showError(
            'Failed to connect after $_maxRetries attempts. Please check your internet connection.');
        _retryAttempts = 0;
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Add this widget for the typing indicator
  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "CassavaCareBot is typing",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Row(
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildPulsingDot(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Add this widget for animated dots
  Widget _buildPulsingDot() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  // Add these new methods
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_chatHistoryKey);
      
      if (history != null) {
        setState(() {
          _messages = history.map((msg) {
            final Map<String, dynamic> decoded = json.decode(msg);
            return {
              'role': decoded['role'] as String,
              'content': decoded['content'] as String,
              'isTyping': decoded['isTyping']?.toString() ?? 'false',
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = _messages.where((msg) => msg['isTyping'] != 'true').map((msg) {
        return json.encode({
          'role': msg['role'],
          'content': msg['content'],
          'isTyping': msg['isTyping'] ?? 'false',
        });
      }).toList();
      await prefs.setStringList(_chatHistoryKey, history);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  // Update the _sendMessage method to properly handle message states
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': message,
        'isTyping': 'false',
      });
      _isLoading = true;
      _isTyping = true;
    });
    
    await _saveChatHistory();
    _controller.clear();

    // Simulate thinking and typing
    await Future.delayed(const Duration(seconds: 1));

    // Find best matching response
    String response = _findBestResponse(message.toLowerCase());

    // Split response into words for realistic typing effect
    List<String> words = response.split(' ');
    String typingResponse = '';

    // Gradually build the response word by word
    for (String word in words) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 150));
      typingResponse += '$word ';
      setState(() {
        _messages.removeWhere((msg) => 
          msg['role'] == 'assistant' && msg['isTyping'] == 'true');
        _messages.add({
          'role': 'assistant',
          'content': typingResponse,
          'isTyping': 'true',
        });
      });
    }

    // Final response
    if (!mounted) return;
    setState(() {
      _messages.removeWhere((msg) => 
        msg['role'] == 'assistant' && msg['isTyping'] == 'true');
      _messages.add({
        'role': 'assistant',
        'content': response,
        'isTyping': 'false',
      });
      _isLoading = false;
      _isTyping = false;
    });

    await _saveChatHistory();
  }

  // Add a method to clear chat history
  Future<void> _clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
      setState(() {
        _messages.clear();
      });
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }

  String _findBestResponse(String query) {
    // Simple keyword matching
    String bestResponse =
        'I apologize, I don\'t have specific information in my database. Please try asking different thing.';
    int bestMatchScore = 0;

    for (var entry in qaDatabase.entries) {
      int matchScore = _calculateMatchScore(query, entry.key);
      if (matchScore > bestMatchScore) {
        bestMatchScore = matchScore;
        bestResponse = entry.value;
      }
    }

    return bestResponse;
  }

  int _calculateMatchScore(String query, String key) {
    // Split into words and count matching keywords
    List<String> queryWords = query.split(' ');
    List<String> keyWords = key.split(' ');
    int score = 0;

    for (String word in queryWords) {
      if (keyWords.contains(word)) score++;
    }

    return score;
  }

  // UI building functions would go here (same as before)

  @override
  Widget build(BuildContext context) {
    // You can use your previously designed chat UI here
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CassavaCareBot',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5D7C4A),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Chat History'),
                    content: const Text('Are you sure you want to clear all chat history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _clearChatHistory();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Clear History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: _buildTypingIndicator(),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.black87 : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: "Ask about cassava diseases...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.green.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.green.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _isLoading ? Colors.grey : const Color(0xFF5D7C4A),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
