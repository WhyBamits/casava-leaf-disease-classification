import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  final String diseaseName;

  const ReportPage({Key? key, required this.diseaseName}) : super(key: key);

  static final Map<String, Map<String, dynamic>> diseaseDetails = {
    "Mosaic": {
      "description":
          "Cassava Mosaic Disease (CMD) is a highly destructive viral disease that affects cassava (Manihot esculenta), a staple food crop in many tropical and subtropical regions, particularly in sub-Saharan Africa. It is characterized by the appearance of light and dark green (mosaic) patterns on cassava leaves, often accompanied by distortion, wrinkling, and narrowing of the leaves. These symptoms can vary in severity depending on the cassava variety, virus strain, environmental conditions, and plant age at infection.CMD interferes with the plant’s ability to photosynthesize efficiently by damaging leaf tissues. This reduction in photosynthetic capacity leads to significant physiological stress, resulting in poor plant vigor, stunted growth, delayed maturity, and, ultimately, low root yield. In severe cases, infected plants may not produce harvestable tubers at all, or the tubers may be extremely small and of poor quality.The disease is caused by a group of related viruses known as Cassava Mosaic Geminiviruses (CMGs). These viruses are primarily spread by the whitefly vector (Bemisia tabaci), which feeds on the underside of cassava leaves and transmits the virus from plant to plant. In addition, CMD spreads rapidly through the use of infected stem cuttings as planting material—a common practice in cassava cultivation.CMD poses a major threat to food security and economic livelihoods, especially for smallholder farmers who depend on cassava as a primary source of income and nutrition. In heavily infected regions, yield losses can range from 20% to over 90%, making CMD one of the most important constraints to cassava production in affected areas.",
      "cause":
          "CMD is caused by a group of viruses known as Cassava mosaic geminiviruses (CMGs), which are primarily transmitted by the whitefly (Bemisia tabaci) and through infected stem cuttings used for planting.",
      "effects":
          "CMD can cause yield losses of up to 90% in severely affected fields. It leads to poor root formation, making cassava unsuitable for consumption or sale. This adversely impacts food security and the economic stability of cassava farmers.",
      "prevention": [
        "Use certified, virus-free planting materials from reliable sources.",
        "Practice regular field inspection and promptly remove infected plants (roguing).",
        "Control whitefly populations using biological or chemical means.",
        "Avoid using stem cuttings from infected fields.",
        "Promote crop diversity to reduce disease pressure."
      ],
    },
    "Blight": {
      "description":
          "Cassava Bacterial Blight (CBB) is a highly destructive disease of cassava caused by the bacterium Xanthomonas axonopodis pv. manihotis. It is one of the most serious bacterial threats to cassava production, especially in humid and tropical environments where conditions favor the rapid multiplication and spread of the pathogen. The disease is primarily characterized by leaf wilting, angular water-soaked lesions that eventually turn dark brown or black, and cankers on stems that lead to shoot dieback. These symptoms typically begin on the lower leaves and progressively move upward. In severe cases, CBB can cause complete defoliation, stem collapse, and ultimately plant death. One of the challenges with managing CBB is that its symptoms often resemble those of other fungal or viral diseases, making accurate field diagnosis difficult without laboratory testing. CBB spreads rapidly through infected planting materials, contaminated tools, rain splash, and insect activity. The bacterium enters the plant through natural openings or wounds caused by pruning, harvesting, or insect feeding. Once inside, it colonizes the plant’s vascular tissues, blocking water transport and causing systemic infection. Economically, the impact of CBB is profound. Infected plants exhibit stunted growth, poor root development, and reduced starch content, making them unsuitable for consumption or processing. Yield losses can range from 20% to 100%, especially in areas with poor management practices or during seasons of high rainfall and humidity.Effective management of CBB requires an integrated approach that includes the use of disease-free planting materials, crop rotation, sanitation measures, and, where available, resistant cassava varieties. Raising farmer awareness and implementing strict phytosanitary measures are also critical in limiting the spread of this damaging disease.",
      "cause":
          "CBB is caused by the bacterium Xanthomonas axonopodis pv. manihotis. It spreads rapidly via infected planting materials, rain splash, contaminated farm tools, and insects.",
      "effects":
          "The disease can destroy entire cassava crops, especially in poorly managed fields. It affects plant vigor, delays maturity, and can make roots rot, leading to significant financial losses.",
      "prevention": [
        "Plant resistant or tolerant cassava varieties where available.",
        "Practice crop rotation with non-host crops like maize or legumes.",
        "Disinfect tools and machinery regularly to prevent spread.",
        "Ensure good field drainage and avoid overhead irrigation.",
        "Remove and destroy infected plant debris after harvest."
      ],
    },
    "Brown Streak": {
      "description":
          "Cassava Brown Streak Disease (CBSD) is a highly destructive viral disease that severely affects cassava, a staple crop and vital source of food security and income for millions of people across sub-Saharan Africa. Although traditionally more prevalent in East and Central Africa, CBSD has become an emerging concern in West Africa, including Ghana, due to increasing cassava trade, seed exchange, and environmental conditions that favor the disease's spread.The disease is primarily caused by two distinct but related viruses: Cassava brown streak virus (CBSV) and Ugandan cassava brown streak virus (UCBSV). These viruses are transmitted by whiteflies (Bemisia tabaci) and through the planting of infected cassava cuttings, which is a common method of propagation in Ghanaian cassava farming communities.CBSD presents a range of symptoms that can be deceptive at first. On the foliage, infected plants show yellowing along the leaf veins, general chlorosis, and sometimes leaf distortion. Brown streaks or lesions often appear on the stems, but the most devastating impact occurs below ground: the cassava roots develop dry, brown, necrotic patches, which make the tubers unfit for consumption or processing. These symptoms may not be visible until harvest, making early detection extremely difficult and allowing the disease to spread unknowingly through the reuse of infected cuttings.In the Ghanaian context, where cassava plays a central role in rural diets, local markets, and agro-industrial supply chains (e.g. gari, cassava flour, and ethanol production), the threat posed by CBSD is profound. Infected fields can suffer yield losses of 30–70%, and in severe outbreaks, up to 100% of tubers may be destroyed. This not only reduces household food availability but also undermines national food security and rural incomes.Furthermore, as Ghana increasingly promotes cassava commercialization and export, the presence of CBSD poses a risk to regional trade and seed certification programs, especially if disease-free planting material is not prioritized.Due to Ghana’s climatic conditions and the mobility of whitefly vectors, CBSD has the potential to spread rapidly if not managed proactively. Farmers, researchers, and extension officers must remain vigilant, and national plant protection agencies must prioritize surveillance, seed certification, and education campaigns to prevent widespread outbreaks",
      "cause":
          "CBSD is caused by two viruses: Cassava brown streak virus (CBSV) and Ugandan cassava brown streak virus (UCBSV). These viruses are transmitted by whiteflies and through infected cuttings.",
      "effects":
          "CBSD causes severe economic losses as infected roots often appear healthy on the outside but are rotten inside, making them unfit for consumption or sale. It also discourages farmers from planting cassava in high-risk regions.",
      "prevention": [
        "Use certified, disease-free planting material from recognized nurseries.",
        "Monitor and control whitefly populations effectively.",
        "Avoid planting cassava in areas with known CBSD outbreaks.",
        "Promote intercropping with legumes or cereals to reduce whitefly attraction.",
        "Train farmers on field hygiene and early disease detection techniques."
      ],
    },
    "Green Mite": {
      "description":
          "Cassava Green Mite (CGM) (Mononychellus tanajoa) is a microscopic pest that poses a significant threat to cassava crops, especially in sub-Saharan Africa and tropical regions. These mites colonize the undersides of cassava leaves, where they feed by piercing plant cells and sucking out the contents. Their feeding results in yellow speckling, leaf curling, chlorosis, and reduced leaf expansion. In the early stages, damage caused by CGM may be subtle and easily overlooked. However, as the infestation intensifies, leaves begin to wither, dry up, and fall off—a condition known as defoliation. This loss of leaf area significantly reduces the plant’s ability to photosynthesize, which in turn stunts growth and diminishes root yield and quality. CGM populations build up rapidly under hot and dry conditions, making drought-stressed plants especially vulnerable. The mites spread quickly between plants through wind, insects, farm tools, and human activity, enabling them to colonize entire fields in a short time.Severe infestations can lead to yield losses of up to 53%, affecting both the quality and quantity of cassava roots. This is particularly devastating for smallholder farmers who rely on cassava as a primary food source and income-generating crop. Effective management of CGM involves Integrated Pest Management (IPM) strategies such as: Planting resistant or tolerant cassava varieties. Encouraging biological control using natural enemies like Typhlodromalus aripo, a predatory mite. Practicing good field sanitation and maintaining proper plant spacing to limit spread. Applying botanical insecticides (e.g., neem extracts) or acaricides if infestation is severe. Early detection and timely intervention are essential to preventing serious economic losses caused by this resilient and fast-replicating pest.",
      "cause":
          "Green mites thrive in hot, dry conditions and spread rapidly from plant to plant through wind, human activity, or contaminated tools and equipment.",
      "effects":
          "Infestations result in stunted cassava plants with fewer and smaller roots. Over time, repeated infestations deplete soil fertility and lower farm productivity.",
      "prevention": [
        "Use mite-resistant cassava varieties developed by agricultural research institutes.",
        "Encourage natural predators such as predatory mites and ladybugs in fields.",
        "Maintain adequate spacing between plants to reduce mite transfer.",
        "Apply neem-based or selective miticides if infestation is high.",
        "Keep the field weed-free to eliminate alternative hosts of the mite."
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final details = diseaseDetails[diseaseName];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F5E9), // light green
            Color(0xFFC8E6C9), // lighter green
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make scaffold transparent
        appBar: AppBar(
          title: Text(
            '$diseaseName Report',
            style: const TextStyle(
              color: Color(0xFF1D3A1A),
              fontWeight: FontWeight.w900,
              fontFamily: 'Roboto',
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white.withOpacity(0.85),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF1D3A1A)),
        ),
        body: details == null
            ? const Center(
                child: Text(
                  "No information available for this disease.",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _headerCard(diseaseName),
                    const SizedBox(height: 24),
                    _infoCard("Description", details["description"]),
                    const SizedBox(height: 18),
                    _infoCard("Cause", details["cause"]),
                    const SizedBox(height: 18),
                    _infoCard("Effects on Farmers and Plants", details["effects"]),
                    const SizedBox(height: 18),
                    _preventionCard("Prevention", List<String>.from(details["prevention"])),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 48, 61, 50),
                          foregroundColor: const Color.fromARGB(255, 8, 7, 7),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text(
                          "Back",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _headerCard(String diseaseName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            "assets/images/logo.png",
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            diseaseName,
            style: const TextStyle(
              color: Color(0xFF1D3A1A),
              fontSize: 28,
              fontWeight: FontWeight.w900, // VERY bold
              fontFamily: 'Roboto',
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // More solid white for contrast
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black, // Changed from Colors.white
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'Roboto',
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.black87, // Changed from Colors.white70
              fontSize: 16,
              height: 1.5,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _preventionCard(String title, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // More solid white for contrast
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black, // Changed from Colors.white
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'Roboto',
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points.map((point) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "• ",
                      style: TextStyle(
                        color: Colors.green, // Changed from Colors.lightGreenAccent
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          color: Colors.black87, // Changed from Colors.white70
                          fontSize: 16,
                          height: 1.5,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
