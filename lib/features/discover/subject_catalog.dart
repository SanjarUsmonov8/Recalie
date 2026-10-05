import 'package:flutter/material.dart';

class DiscoverSubject {
  const DiscoverSubject({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.parts,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final List<SubjectPart> parts;
}

class SubjectPart {
  const SubjectPart({
    required this.title,
    required this.description,
    required this.topics,
  });

  final String title;
  final String description;
  final List<ReviewTopic> topics;
}

class ReviewTopic {
  const ReviewTopic({required this.title, required this.summary});

  final String title;
  final String summary;

  String memoryText({
    required String subjectName,
    required String partTitle,
  }) {
    return '''$subjectName — $partTitle

$title

$summary

Review checklist
• Define the central terms without looking at your notes.
• Explain how the main ideas are connected.
• Create at least two examples and one counterexample.
• Compare this topic with the other ideas in $partTitle.
• Write a short summary entirely from memory.

Active-recall prompts
1. How would you explain $title to a beginner?
2. Which facts, rules, or processes are essential?
3. Where is this knowledge applied?
4. What is easy to confuse, and how can you distinguish it?
5. Which question could test whether you truly understand it?''';
  }
}

const discoverSubjects = <DiscoverSubject>[
  DiscoverSubject(
    name: 'English',
    subtitle: 'Words, grammar, and literature',
    icon: Icons.translate_rounded,
    colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
    parts: [
      SubjectPart(
        title: 'Language foundations',
        description: 'Build accurate vocabulary, sentences, and grammar.',
        topics: [
          ReviewTopic(
            title: 'Parts of speech',
            summary:
                'Review how nouns, verbs, adjectives, adverbs, pronouns, prepositions, conjunctions, and interjections function inside sentences.',
          ),
          ReviewTopic(
            title: 'Sentence structure',
            summary:
                'Study subjects, predicates, phrases, clauses, sentence types, agreement, and the punctuation that makes meaning clear.',
          ),
          ReviewTopic(
            title: 'Tense and grammar patterns',
            summary:
                'Compare the major verb tenses and practise choosing forms that express time, continuity, completion, and possibility.',
          ),
        ],
      ),
      SubjectPart(
        title: 'Reading and writing',
        description: 'Understand texts and communicate ideas clearly.',
        topics: [
          ReviewTopic(
            title: 'Vocabulary in context',
            summary:
                'Use roots, affixes, surrounding clues, collocations, and word families to learn and retrieve vocabulary efficiently.',
          ),
          ReviewTopic(
            title: 'Reading analysis',
            summary:
                'Identify main ideas, evidence, tone, purpose, inference, structure, and the difference between fact and interpretation.',
          ),
          ReviewTopic(
            title: 'Essay construction',
            summary:
                'Plan a thesis, organize paragraphs, connect claims to evidence, use transitions, and revise for clarity and precision.',
          ),
        ],
      ),
    ],
  ),
  DiscoverSubject(
    name: 'Mathematics',
    subtitle: 'Formulas, rules, and methods',
    icon: Icons.calculate_rounded,
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    parts: [
      SubjectPart(
        title: 'Numbers and algebra',
        description: 'Develop fluency with quantities, symbols, and patterns.',
        topics: [
          ReviewTopic(
            title: 'Arithmetic and proportions',
            summary:
                'Review fractions, decimals, percentages, ratios, rates, powers, roots, and proportional reasoning through worked examples.',
          ),
          ReviewTopic(
            title: 'Equations and inequalities',
            summary:
                'Practise simplifying expressions and solving linear equations, simultaneous equations, and inequalities while checking solutions.',
          ),
          ReviewTopic(
            title: 'Functions and graphs',
            summary:
                'Connect equations, tables, graphs, domain, range, slope, intercepts, and transformations as different views of a function.',
          ),
        ],
      ),
      SubjectPart(
        title: 'Geometry and data',
        description: 'Reason about space, uncertainty, and evidence.',
        topics: [
          ReviewTopic(
            title: 'Geometry and measurement',
            summary:
                'Study angles, similarity, congruence, coordinates, perimeter, area, surface area, volume, and common geometric proofs.',
          ),
          ReviewTopic(
            title: 'Probability',
            summary:
                'Use sample spaces, complements, independence, conditional probability, and expected value to reason about uncertainty.',
          ),
          ReviewTopic(
            title: 'Statistics',
            summary:
                'Interpret distributions using center, spread, outliers, sampling, correlation, and the limits of conclusions drawn from data.',
          ),
        ],
      ),
    ],
  ),
  DiscoverSubject(
    name: 'Physics',
    subtitle: 'Laws, units, and equations',
    icon: Icons.bolt_rounded,
    colors: [Color(0xFF0F766E), Color(0xFF2DD4BF)],
    parts: [
      SubjectPart(
        title: 'Mechanics',
        description: 'Explain motion and the interactions that change it.',
        topics: [
          ReviewTopic(
            title: 'Motion and graphs',
            summary:
                'Relate displacement, velocity, acceleration, time, vectors, and the gradients and areas of motion graphs.',
          ),
          ReviewTopic(
            title: 'Forces and Newton’s laws',
            summary:
                'Draw free-body diagrams and apply inertia, force, mass, acceleration, action–reaction pairs, friction, and weight.',
          ),
          ReviewTopic(
            title: 'Energy and momentum',
            summary:
                'Compare work, power, kinetic and potential energy, conservation laws, impulse, momentum, and collision models.',
          ),
        ],
      ),
      SubjectPart(
        title: 'Waves and electricity',
        description: 'Connect oscillations, fields, energy, and circuits.',
        topics: [
          ReviewTopic(
            title: 'Waves, sound, and light',
            summary:
                'Review wavelength, frequency, speed, amplitude, reflection, refraction, diffraction, interference, sound, and the spectrum.',
          ),
          ReviewTopic(
            title: 'Electric circuits',
            summary:
                'Relate charge, current, potential difference, resistance, power, series circuits, parallel circuits, and circuit measurements.',
          ),
          ReviewTopic(
            title: 'Fields and electromagnetism',
            summary:
                'Study gravitational, electric, and magnetic fields, forces at a distance, induction, motors, and generators.',
          ),
        ],
      ),
    ],
  ),
  DiscoverSubject(
    name: 'Chemistry',
    subtitle: 'Elements, reactions, and structures',
    icon: Icons.science_rounded,
    colors: [Color(0xFFDB2777), Color(0xFFF472B6)],
    parts: [
      SubjectPart(
        title: 'Particles and reactions',
        description: 'Understand matter from atoms to chemical equations.',
        topics: [
          ReviewTopic(
            title: 'Atomic structure and periodicity',
            summary:
                'Review protons, neutrons, electrons, isotopes, electron arrangement, ions, and trends across groups and periods.',
          ),
          ReviewTopic(
            title: 'Bonding and structure',
            summary:
                'Compare ionic, covalent, and metallic bonding and connect microscopic structure to observable material properties.',
          ),
          ReviewTopic(
            title: 'Equations and stoichiometry',
            summary:
                'Balance reactions and use moles, molar mass, concentration, gas volume, limiting reactants, and yield calculations.',
          ),
        ],
      ),
      SubjectPart(
        title: 'Chemical systems',
        description: 'Predict how and why chemical systems change.',
        topics: [
          ReviewTopic(
            title: 'Acids, bases, and salts',
            summary:
                'Study pH, indicators, neutralization, strong and weak acids, titration reasoning, and common salt preparations.',
          ),
          ReviewTopic(
            title: 'Energy, rates, and equilibrium',
            summary:
                'Connect energy profiles, activation energy, collision theory, catalysts, reversible reactions, and equilibrium shifts.',
          ),
          ReviewTopic(
            title: 'Organic chemistry foundations',
            summary:
                'Recognize homologous series, functional groups, naming patterns, structural formulas, reactions, polymers, and isomers.',
          ),
        ],
      ),
    ],
  ),
  DiscoverSubject(
    name: 'Biology',
    subtitle: 'Life, anatomy, and ecosystems',
    icon: Icons.biotech_rounded,
    colors: [Color(0xFF15803D), Color(0xFF4ADE80)],
    parts: [
      SubjectPart(
        title: 'Cells and inheritance',
        description: 'Trace life processes from cells to genetic information.',
        topics: [
          ReviewTopic(
            title: 'Cells and transport',
            summary:
                'Compare cell structures and relate diffusion, osmosis, active transport, microscopy, specialization, tissues, and organs.',
          ),
          ReviewTopic(
            title: 'Metabolism and enzymes',
            summary:
                'Study enzyme action, respiration, photosynthesis, limiting factors, energy transfer, and regulation of reactions.',
          ),
          ReviewTopic(
            title: 'Genetics and cell division',
            summary:
                'Connect DNA, genes, chromosomes, protein synthesis, mitosis, meiosis, inheritance, variation, and mutation.',
          ),
        ],
      ),
      SubjectPart(
        title: 'Organisms and environments',
        description: 'Understand coordinated organisms and changing ecosystems.',
        topics: [
          ReviewTopic(
            title: 'Human body systems',
            summary:
                'Review digestion, circulation, breathing, excretion, nervous and hormonal control, immunity, and homeostasis.',
          ),
          ReviewTopic(
            title: 'Evolution and classification',
            summary:
                'Connect variation, natural selection, adaptation, speciation, evidence for evolution, and classification systems.',
          ),
          ReviewTopic(
            title: 'Ecology',
            summary:
                'Study food webs, nutrient cycles, populations, sampling, biodiversity, human impacts, and ecosystem conservation.',
          ),
        ],
      ),
    ],
  ),
  DiscoverSubject(
    name: 'History',
    subtitle: 'Dates, people, and events',
    icon: Icons.account_balance_rounded,
    colors: [Color(0xFFB45309), Color(0xFFFBBF24)],
    parts: [
      SubjectPart(
        title: 'Building historical understanding',
        description: 'Organize evidence, chronology, causes, and consequences.',
        topics: [
          ReviewTopic(
            title: 'Chronology and periodization',
            summary:
                'Build timelines, identify turning points, compare periods, and distinguish continuity from meaningful historical change.',
          ),
          ReviewTopic(
            title: 'Sources and evidence',
            summary:
                'Evaluate origin, purpose, context, audience, reliability, limitation, and corroboration across primary and secondary sources.',
          ),
          ReviewTopic(
            title: 'Cause and consequence',
            summary:
                'Separate long-term conditions, short-term triggers, individual actions, structural forces, intended results, and unintended effects.',
          ),
        ],
      ),
      SubjectPart(
        title: 'World history themes',
        description: 'Connect states, societies, revolutions, and conflicts.',
        topics: [
          ReviewTopic(
            title: 'Empires and states',
            summary:
                'Compare how states gained legitimacy, governed territory, collected resources, expanded power, and responded to resistance.',
          ),
          ReviewTopic(
            title: 'Revolutions and industrialization',
            summary:
                'Trace political and industrial revolutions through ideas, technology, class, labor, urbanization, reform, and global impact.',
          ),
          ReviewTopic(
            title: 'Modern conflicts and cooperation',
            summary:
                'Review nationalism, imperialism, world wars, decolonization, international institutions, and competing interpretations of events.',
          ),
        ],
      ),
    ],
  ),
  DiscoverSubject(
    name: 'Geography',
    subtitle: 'Places, maps, and environments',
    icon: Icons.public_rounded,
    colors: [Color(0xFF0369A1), Color(0xFF38BDF8)],
    parts: [
      SubjectPart(
        title: 'Physical geography',
        description: 'Explain Earth’s landscapes, weather, and ecosystems.',
        topics: [
          ReviewTopic(
            title: 'Earth structure and landforms',
            summary:
                'Connect plate tectonics, rocks, weathering, erosion, rivers, coasts, glaciers, hazards, and landscape formation.',
          ),
          ReviewTopic(
            title: 'Weather and climate',
            summary:
                'Study atmospheric processes, pressure, winds, precipitation, climate controls, extreme weather, evidence, and climate change.',
          ),
          ReviewTopic(
            title: 'Ecosystems and resources',
            summary:
                'Compare biomes, energy and nutrient flows, soils, water, resource use, sustainability, and ecosystem management.',
          ),
        ],
      ),
      SubjectPart(
        title: 'Human geography',
        description: 'Understand populations, settlements, and global links.',
        topics: [
          ReviewTopic(
            title: 'Population and migration',
            summary:
                'Interpret population structure, demographic change, push–pull factors, migration flows, impacts, and policy responses.',
          ),
          ReviewTopic(
            title: 'Cities and development',
            summary:
                'Review urbanization, land use, inequality, services, informal settlements, development measures, and sustainable planning.',
          ),
          ReviewTopic(
            title: 'Globalization and economies',
            summary:
                'Trace trade, production, transport, transnational companies, changing employment, interdependence, and uneven development.',
          ),
        ],
      ),
    ],
  ),
  DiscoverSubject(
    name: 'Computer science',
    subtitle: 'Concepts, syntax, and systems',
    icon: Icons.code_rounded,
    colors: [Color(0xFF334155), Color(0xFF64748B)],
    parts: [
      SubjectPart(
        title: 'Computing foundations',
        description: 'Understand how information and instructions are represented.',
        topics: [
          ReviewTopic(
            title: 'Data representation',
            summary:
                'Review binary, hexadecimal, units, text encoding, images, sound, compression, and the trade-offs of digital representation.',
          ),
          ReviewTopic(
            title: 'Algorithms and complexity',
            summary:
                'Express algorithms clearly and compare searching, sorting, correctness, efficiency, decomposition, abstraction, and edge cases.',
          ),
          ReviewTopic(
            title: 'Hardware and architecture',
            summary:
                'Connect processors, memory, storage, input/output, instructions, operating systems, and performance limitations.',
          ),
        ],
      ),
      SubjectPart(
        title: 'Programming and systems',
        description: 'Build reliable programs and connected systems.',
        topics: [
          ReviewTopic(
            title: 'Programming constructs',
            summary:
                'Practise variables, types, selection, iteration, functions, collections, validation, testing, debugging, and readable design.',
          ),
          ReviewTopic(
            title: 'Data structures and databases',
            summary:
                'Compare arrays, lists, stacks, queues, trees, tables, keys, relationships, queries, normalization, and appropriate use cases.',
          ),
          ReviewTopic(
            title: 'Networks and cybersecurity',
            summary:
                'Review protocols, addressing, routing, layers, encryption, authentication, threats, vulnerabilities, defenses, and human factors.',
          ),
        ],
      ),
    ],
  ),
  DiscoverSubject(
    name: 'Medicine',
    subtitle: 'Terms, systems, and treatments',
    icon: Icons.medical_services_rounded,
    colors: [Color(0xFFDC2626), Color(0xFFFB7185)],
    parts: [
      SubjectPart(
        title: 'Biomedical foundations',
        description: 'Organize anatomy, physiology, and disease mechanisms.',
        topics: [
          ReviewTopic(
            title: 'Anatomical language',
            summary:
                'Review planes, directions, regions, cavities, tissue organization, major structures, and terminology used to describe the body.',
          ),
          ReviewTopic(
            title: 'Physiology and homeostasis',
            summary:
                'Connect feedback loops, fluid balance, temperature, metabolism, transport, signaling, and coordination between organ systems.',
          ),
          ReviewTopic(
            title: 'Pathology foundations',
            summary:
                'Study causes of disease, cell injury, inflammation, infection, immune responses, healing, degeneration, and neoplasia.',
          ),
        ],
      ),
      SubjectPart(
        title: 'Clinical foundations',
        description: 'Structure safe assessment and treatment knowledge.',
        topics: [
          ReviewTopic(
            title: 'History and examination',
            summary:
                'Organize presenting concerns, symptom analysis, past and family history, medicines, observations, examination, and documentation.',
          ),
          ReviewTopic(
            title: 'Diagnostics and reasoning',
            summary:
                'Build differential diagnoses and interpret probability, tests, sensitivity, specificity, imaging, laboratory results, and red flags.',
          ),
          ReviewTopic(
            title: 'Pharmacology principles',
            summary:
                'Review drug targets, dose, absorption, distribution, metabolism, elimination, adverse effects, interactions, and safe prescribing.',
          ),
        ],
      ),
    ],
  ),
  DiscoverSubject(
    name: 'Law',
    subtitle: 'Cases, principles, and terminology',
    icon: Icons.gavel_rounded,
    colors: [Color(0xFF4338CA), Color(0xFF818CF8)],
    parts: [
      SubjectPart(
        title: 'Legal foundations',
        description: 'Understand authority, reasoning, and legal institutions.',
        topics: [
          ReviewTopic(
            title: 'Sources of law',
            summary:
                'Compare constitutions, legislation, regulations, judicial decisions, precedent, custom, treaties, and their relative authority.',
          ),
          ReviewTopic(
            title: 'Courts and procedure',
            summary:
                'Review jurisdiction, court hierarchy, parties, pleadings, evidence, burdens and standards of proof, judgments, and appeals.',
          ),
          ReviewTopic(
            title: 'Legal reasoning',
            summary:
                'Identify issues, rules, material facts, analogies, distinctions, interpretation, application, counterarguments, and conclusions.',
          ),
        ],
      ),
      SubjectPart(
        title: 'Major fields of law',
        description: 'Separate the core rules and remedies of major fields.',
        topics: [
          ReviewTopic(
            title: 'Contract and tort',
            summary:
                'Compare agreement, consideration, terms, breach, duty, negligence, causation, defenses, damages, and other remedies.',
          ),
          ReviewTopic(
            title: 'Criminal law',
            summary:
                'Review act and fault requirements, offenses, participation, attempts, defenses, burdens of proof, sentencing, and policy debates.',
          ),
          ReviewTopic(
            title: 'Public and constitutional law',
            summary:
                'Study state powers, separation of powers, rights, administrative decisions, judicial review, proportionality, and accountability.',
          ),
        ],
      ),
    ],
  ),
];
