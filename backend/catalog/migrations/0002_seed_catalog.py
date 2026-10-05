from django.db import migrations


CATALOG = [
    ('english', 'English', 'Words, grammar, and literature', 'translate', '#2563EB', '#60A5FA', [
        ('Language foundations', 'Build accurate vocabulary, sentences, and grammar.', [
            ('Parts of speech', 'How nouns, verbs, adjectives, adverbs, pronouns, prepositions, conjunctions, and interjections function inside sentences.'),
            ('Sentence structure', 'Subjects, predicates, phrases, clauses, sentence types, agreement, and punctuation that makes meaning clear.'),
            ('Tense and grammar patterns', 'Verb tenses and forms that express time, continuity, completion, possibility, and relationships between events.'),
        ]),
        ('Reading and writing', 'Understand texts and communicate ideas clearly.', [
            ('Vocabulary in context', 'Roots, affixes, context clues, collocations, and word families for learning and retrieving vocabulary.'),
            ('Reading analysis', 'Main ideas, evidence, tone, purpose, inference, structure, and the difference between fact and interpretation.'),
            ('Essay construction', 'Thesis development, paragraph organization, evidence, transitions, revision, clarity, and precision.'),
        ]),
    ]),
    ('mathematics', 'Mathematics', 'Formulas, rules, and methods', 'calculate', '#7C3AED', '#A78BFA', [
        ('Numbers and algebra', 'Develop fluency with quantities, symbols, and patterns.', [
            ('Arithmetic and proportions', 'Fractions, decimals, percentages, ratios, rates, powers, roots, and proportional reasoning.'),
            ('Equations and inequalities', 'Simplifying expressions and solving linear equations, simultaneous equations, and inequalities.'),
            ('Functions and graphs', 'Equations, tables, graphs, domain, range, slope, intercepts, and transformations as views of a function.'),
        ]),
        ('Geometry and data', 'Reason about space, uncertainty, and evidence.', [
            ('Geometry and measurement', 'Angles, similarity, congruence, coordinates, perimeter, area, surface area, volume, and proof.'),
            ('Probability', 'Sample spaces, complements, independence, conditional probability, and expected value.'),
            ('Statistics', 'Distributions, center, spread, outliers, sampling, correlation, and limits of conclusions from data.'),
        ]),
    ]),
    ('physics', 'Physics', 'Laws, units, and equations', 'bolt', '#0F766E', '#2DD4BF', [
        ('Mechanics', 'Explain motion and the interactions that change it.', [
            ('Motion and graphs', 'Displacement, velocity, acceleration, time, vectors, and gradients and areas of motion graphs.'),
            ('Forces and Newton’s laws', 'Free-body diagrams, inertia, mass, acceleration, action–reaction pairs, friction, and weight.'),
            ('Energy and momentum', 'Work, power, kinetic and potential energy, conservation, impulse, momentum, and collisions.'),
        ]),
        ('Waves and electricity', 'Connect oscillations, fields, energy, and circuits.', [
            ('Waves, sound, and light', 'Wavelength, frequency, speed, amplitude, reflection, refraction, diffraction, interference, and spectra.'),
            ('Electric circuits', 'Charge, current, potential difference, resistance, power, and series and parallel circuits.'),
            ('Fields and electromagnetism', 'Gravitational, electric, and magnetic fields, induction, motors, and generators.'),
        ]),
    ]),
    ('chemistry', 'Chemistry', 'Elements, reactions, and structures', 'science', '#DB2777', '#F472B6', [
        ('Particles and reactions', 'Understand matter from atoms to chemical equations.', [
            ('Atomic structure and periodicity', 'Protons, neutrons, electrons, isotopes, electron arrangements, ions, groups, periods, and trends.'),
            ('Bonding and structure', 'Ionic, covalent, and metallic bonding and links between structure and material properties.'),
            ('Equations and stoichiometry', 'Balanced reactions, moles, molar mass, concentration, limiting reactants, and yield.'),
        ]),
        ('Chemical systems', 'Predict how and why chemical systems change.', [
            ('Acids, bases, and salts', 'pH, indicators, neutralization, strong and weak acids, titrations, and salt preparation.'),
            ('Energy, rates, and equilibrium', 'Energy profiles, activation energy, collision theory, catalysts, reversibility, and equilibrium shifts.'),
            ('Organic chemistry foundations', 'Homologous series, functional groups, naming, structures, reactions, polymers, and isomers.'),
        ]),
    ]),
    ('biology', 'Biology', 'Life, anatomy, and ecosystems', 'biotech', '#15803D', '#4ADE80', [
        ('Cells and inheritance', 'Trace life processes from cells to genetic information.', [
            ('Cells and transport', 'Cell structures, diffusion, osmosis, active transport, microscopy, specialization, tissues, and organs.'),
            ('Metabolism and enzymes', 'Enzyme action, respiration, photosynthesis, limiting factors, energy transfer, and regulation.'),
            ('Genetics and cell division', 'DNA, genes, chromosomes, protein synthesis, mitosis, meiosis, inheritance, and mutation.'),
        ]),
        ('Organisms and environments', 'Understand coordinated organisms and changing ecosystems.', [
            ('Human body systems', 'Digestion, circulation, breathing, excretion, nervous and hormonal control, immunity, and homeostasis.'),
            ('Evolution and classification', 'Variation, natural selection, adaptation, speciation, evolutionary evidence, and classification.'),
            ('Ecology', 'Food webs, nutrient cycles, populations, sampling, biodiversity, human impacts, and conservation.'),
        ]),
    ]),
    ('history', 'History', 'Dates, people, and events', 'account_balance', '#B45309', '#FBBF24', [
        ('Historical understanding', 'Organize evidence, chronology, causes, and consequences.', [
            ('Chronology and periodization', 'Timelines, turning points, periods, continuity, and meaningful historical change.'),
            ('Sources and evidence', 'Origin, purpose, context, audience, reliability, limitation, and corroboration of sources.'),
            ('Cause and consequence', 'Long-term conditions, triggers, actions, structures, intended results, and unintended effects.'),
        ]),
        ('World history themes', 'Connect states, societies, revolutions, and conflicts.', [
            ('Empires and states', 'Legitimacy, governance, resources, territorial expansion, administration, and resistance.'),
            ('Revolutions and industrialization', 'Ideas, technology, class, labor, urbanization, reform, and global impact.'),
            ('Modern conflicts and cooperation', 'Nationalism, imperialism, world wars, decolonization, institutions, and interpretations.'),
        ]),
    ]),
    ('geography', 'Geography', 'Places, maps, and environments', 'public', '#0369A1', '#38BDF8', [
        ('Physical geography', 'Explain Earth’s landscapes, weather, and ecosystems.', [
            ('Earth structure and landforms', 'Plate tectonics, rocks, weathering, erosion, rivers, coasts, glaciers, and hazards.'),
            ('Weather and climate', 'Atmospheric processes, pressure, winds, precipitation, climate controls, extremes, and climate change.'),
            ('Ecosystems and resources', 'Biomes, energy and nutrient flows, soils, water, resources, sustainability, and management.'),
        ]),
        ('Human geography', 'Understand populations, settlements, and global links.', [
            ('Population and migration', 'Population structure, demographic change, push–pull factors, migration, impacts, and policy.'),
            ('Cities and development', 'Urbanization, land use, inequality, services, development measures, and sustainable planning.'),
            ('Globalization and economies', 'Trade, production, transport, companies, employment, interdependence, and uneven development.'),
        ]),
    ]),
    ('computer-science', 'Computer science', 'Concepts, syntax, and systems', 'code', '#334155', '#64748B', [
        ('Computing foundations', 'Understand how information and instructions are represented.', [
            ('Data representation', 'Binary, hexadecimal, units, encoding, images, sound, compression, and digital trade-offs.'),
            ('Algorithms and complexity', 'Searching, sorting, correctness, efficiency, decomposition, abstraction, and edge cases.'),
            ('Hardware and architecture', 'Processors, memory, storage, input/output, instructions, operating systems, and performance.'),
        ]),
        ('Programming and systems', 'Build reliable programs and connected systems.', [
            ('Programming constructs', 'Variables, types, selection, iteration, functions, collections, validation, testing, and debugging.'),
            ('Data structures and databases', 'Arrays, lists, stacks, queues, trees, tables, keys, relationships, and queries.'),
            ('Networks and cybersecurity', 'Protocols, addressing, routing, encryption, authentication, threats, and defenses.'),
        ]),
    ]),
    ('medicine', 'Medicine', 'Terms, systems, and treatments', 'medical_services', '#DC2626', '#FB7185', [
        ('Biomedical foundations', 'Organize anatomy, physiology, and disease mechanisms.', [
            ('Anatomical language', 'Planes, directions, regions, cavities, tissues, major structures, and descriptive terminology.'),
            ('Physiology and homeostasis', 'Feedback, fluid balance, temperature, metabolism, transport, signaling, and coordination.'),
            ('Pathology foundations', 'Disease causes, cell injury, inflammation, infection, immunity, healing, and neoplasia.'),
        ]),
        ('Clinical foundations', 'Structure safe assessment and treatment knowledge.', [
            ('History and examination', 'Presenting concerns, symptoms, history, medicines, observations, examination, and documentation.'),
            ('Diagnostics and reasoning', 'Differential diagnoses, probability, test properties, imaging, laboratory results, and red flags.'),
            ('Pharmacology principles', 'Drug targets, dose, absorption, distribution, metabolism, elimination, effects, and interactions.'),
        ]),
    ]),
    ('law', 'Law', 'Cases, principles, and terminology', 'gavel', '#4338CA', '#818CF8', [
        ('Legal foundations', 'Understand authority, reasoning, and legal institutions.', [
            ('Sources of law', 'Constitutions, legislation, regulations, judicial decisions, precedent, custom, and treaties.'),
            ('Courts and procedure', 'Jurisdiction, hierarchy, parties, evidence, burdens of proof, judgments, and appeals.'),
            ('Legal reasoning', 'Issues, rules, facts, analogies, distinctions, interpretation, application, and conclusions.'),
        ]),
        ('Major fields of law', 'Separate the core rules and remedies of major fields.', [
            ('Contract and tort', 'Agreement, terms, breach, duty, negligence, causation, defenses, damages, and remedies.'),
            ('Criminal law', 'Acts, fault, offenses, participation, attempts, defenses, proof, and sentencing.'),
            ('Public and constitutional law', 'State powers, separation, rights, administrative decisions, review, and accountability.'),
        ]),
    ]),
]


def seed_catalog(apps, schema_editor):
    Subject = apps.get_model('catalog', 'Subject')
    SubjectPart = apps.get_model('catalog', 'SubjectPart')
    ReviewBlock = apps.get_model('catalog', 'ReviewBlock')
    for subject_position, (slug, name, subtitle, icon, start, end, parts) in enumerate(CATALOG):
        subject = Subject.objects.create(
            slug=slug,
            name=name,
            subtitle=subtitle,
            icon=icon,
            color_start=start,
            color_end=end,
            position=subject_position,
        )
        for part_position, (part_title, part_description, topics) in enumerate(parts):
            part = SubjectPart.objects.create(
                subject=subject,
                title=part_title,
                description=part_description,
                position=part_position,
            )
            for topic_position, (title, summary) in enumerate(topics):
                ReviewBlock.objects.create(
                    part=part,
                    title=title,
                    summary=summary,
                    key_points=(
                        f'Define the essential terms in {title}.\n'
                        f'Connect the central ideas to {part_title}.\n'
                        'Work through representative examples and common exceptions.\n'
                        'Compare easily confused ideas and explain the differences.'
                    ),
                    recall_prompts=(
                        f'How would you explain {title} to a beginner?\n'
                        'Which facts, rules, or processes are essential?\n'
                        'Where can this knowledge be applied?\n'
                        'What is easiest to confuse in this topic?'
                    ),
                    estimated_minutes=50,
                    position=topic_position,
                )


def remove_catalog(apps, schema_editor):
    apps.get_model('catalog', 'Subject').objects.filter(
        slug__in=[entry[0] for entry in CATALOG]
    ).delete()


class Migration(migrations.Migration):
    dependencies = [('catalog', '0001_initial')]
    operations = [migrations.RunPython(seed_catalog, remove_catalog)]
