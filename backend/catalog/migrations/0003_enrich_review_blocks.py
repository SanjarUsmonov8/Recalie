from django.db import migrations


CONTENT = {
    'mathematics': {
        'Arithmetic and proportions': (
            'Ratios compare quantities by division, while rates compare quantities with different units. '
            'Convert percentages to decimals before multiplying, and keep units visible through each step.',
            [
                'Percentage change = (change ÷ original value) × 100%. A 15% increase means multiply by 1.15; a 15% decrease means multiply by 0.85.',
                'For a:b = c:d, cross-multiplication gives ad = bc. Keep the order of corresponding quantities consistent.',
                'Index rules: aᵐaⁿ = aᵐ⁺ⁿ, aᵐ/aⁿ = aᵐ⁻ⁿ (a ≠ 0), and (aᵐ)ⁿ = aᵐⁿ.',
            ],
            [
                'A jacket costs 80 and is reduced by 15%. What is the sale price, and why is multiplying by 0.85 equivalent?',
                'If 3 workers complete a job in 8 hours at the same rate, how long would 6 workers take?',
                'Which index law simplifies 2³ × 2⁴, and what assumption lets you combine the exponents?',
            ],
        ),
        'Equations and inequalities': (
            'An equation states that two expressions have equal value. Apply inverse operations to both sides, '
            'then substitute the result back to check it. Inequalities follow the same steps except that multiplying '
            'or dividing by a negative reverses the inequality sign.',
            [
                'For ax + b = c, isolate x: x = (c − b)/a, provided a ≠ 0.',
                'For simultaneous linear equations, elimination combines equations to remove one variable; substitution replaces one variable with an equivalent expression.',
                'When −2x < 6, dividing by −2 reverses the sign: x > −3. Always test a value from the solution region.',
            ],
            [
                'Solve 3(2x − 1) = 15 and verify your answer by substitution.',
                'Why does dividing an inequality by a negative number reverse its direction?',
                'When is elimination more convenient than substitution for a pair of linear equations?',
            ],
        ),
        'Functions and graphs': (
            'A function maps each allowed input to exactly one output. A graph makes the relationship visible: '
            'its intercepts show values at the axes, while slope describes the rate of change for a straight line.',
            [
                'For a straight line, y = mx + c; slope m = (y₂ − y₁)/(x₂ − x₁), and c is the y-intercept.',
                'The domain is the set of permitted inputs and the range is the set of resulting outputs. Check restrictions such as a zero denominator or an even root of a negative value.',
                'A translation y = f(x − a) + b moves the graph right by a and up by b; the sign inside the brackets acts in the opposite direction.',
            ],
            [
                'Find the equation of a line through (2, 3) and (6, 11), then interpret its slope.',
                'For f(x) = 1/(x − 4), which input is excluded from the domain and why?',
                'Describe the transformations that turn y = x² into y = (x − 2)² + 3.',
            ],
        ),
        'Geometry and measurement': (
            'Geometry links diagrams, measurements, and logical proof. Mark known equal lengths and angles before choosing '
            'a theorem, and keep squared or cubed units in area and volume calculations.',
            [
                'Triangle area = ½bh; circle area = πr² and circumference = 2πr.',
                'For a right triangle, a² + b² = c². Similar shapes have equal corresponding angles and proportional corresponding lengths.',
                'Prism volume = cross-sectional area × length; cylinder volume = πr²h. Surface area counts every exposed face.',
            ],
            [
                'A right triangle has legs 6 cm and 8 cm. Find its hypotenuse and state the theorem used.',
                'If two similar shapes have a length scale factor of 3, what are the area and volume scale factors?',
                'Which units should be used for the area and volume of a 4 cm by 5 cm by 6 cm box?',
            ],
        ),
        'Probability': (
            'Probability measures how likely an event is, from 0 (impossible) to 1 (certain). A sample space lists '
            'possible outcomes; diagrams or tables help prevent outcomes from being missed.',
            [
                'P(A) = number of favorable outcomes ÷ number of equally likely outcomes.',
                'Complement rule: P(not A) = 1 − P(A). For independent events, P(A and B) = P(A)P(B).',
                'Conditional probability: P(A | B) = P(A and B)/P(B), when P(B) > 0. Expected value = Σ[value × probability].',
            ],
            [
                'A fair die is rolled twice. What is the probability of getting two sixes, and which rule applies?',
                'A bag has 3 red and 2 blue counters. How does the probability of a second red change if the first counter is not replaced?',
                'What does an expected value of 4.2 mean if the result of one trial must be a whole number?',
            ],
        ),
        'Statistics': (
            'Statistics describes a data set and helps judge how representative it is. Pair a measure of center with '
            'a measure of spread, and inspect the graph for skew, clusters, and unusual values.',
            [
                'Mean = Σx/n; median is the middle ordered value; mode is the most frequent value. An outlier can pull the mean strongly.',
                'Range = maximum − minimum. Interquartile range (IQR) = Q₃ − Q₁ and describes the spread of the middle half.',
                'For a population, variance σ² = Σ(x − μ)²/N and standard deviation σ is its square root. Correlation does not by itself establish causation.',
            ],
            [
                'For 2, 3, 3, 4, 18, compare the mean and median. Which better represents a typical value and why?',
                'What does a large IQR tell you about the middle half of a data set?',
                'A survey finds that ice-cream sales and swimming both rise in summer. Why is that not enough to show one causes the other?',
            ],
        ),
    },
    'physics': {
        'Motion and graphs': (
            'Describe motion with a chosen reference point and consistent units. Displacement is directional, while '
            'distance is total path length; velocity and acceleration are rates of change.',
            [
                'Average speed = distance/time; average velocity = displacement/time; acceleration = (final velocity − initial velocity)/time.',
                'For constant acceleration: v = u + at, s = ut + ½at², and v² = u² + 2as. Use only when acceleration is constant.',
                'On a displacement–time graph, gradient is velocity. On a velocity–time graph, gradient is acceleration and signed area is displacement.',
            ],
            [
                'A runner travels 150 m in 25 s. Find the average speed with units.',
                'A car accelerates from 4 m/s to 16 m/s in 6 s. Find its average acceleration.',
                'What does a horizontal section on a velocity–time graph mean, and what does its area represent?',
            ],
        ),
        'Forces and Newton’s laws': (
            'A force is an interaction that can change motion or shape. Draw a free-body diagram for one object, '
            'then add only the external forces acting on it.',
            [
                'Newton’s second law: resultant force F = ma. Weight near Earth is W = mg, where g ≈ 9.8 N/kg.',
                'Newton’s first law: with zero resultant force, velocity remains constant. Equilibrium means forces balance, not necessarily that the object is motionless.',
                'Newton’s third-law forces are equal and opposite but act on different objects, so they do not cancel on one object’s diagram.',
            ],
            [
                'A 2 kg cart has a resultant force of 10 N. Find its acceleration.',
                'How is mass different from weight, and what is the weight of a 5 kg object near Earth?',
                'For a book resting on a table, identify the action–reaction pair involving the book and table.',
            ],
        ),
        'Energy and momentum': (
            'Energy can be transferred between stores, while momentum describes motion and is conserved in an isolated '
            'system. Choose a system boundary before applying a conservation rule.',
            [
                'Work done W = Fs cos θ; power P = W/t. Kinetic energy Eₖ = ½mv² and gravitational potential energy near Earth Eₚ = mgh.',
                'In an isolated system, total energy is conserved, though some may spread into thermal stores and become less useful.',
                'Momentum p = mv; impulse J = FΔt = Δp. In a collision with negligible external impulse, total momentum before equals total momentum after.',
            ],
            [
                'How much kinetic energy does a 3 kg object have at 4 m/s?',
                'Why can total energy remain conserved while a moving object slows down?',
                'A 0.2 kg ball changes velocity from 10 m/s to −5 m/s. Find its change in momentum.',
            ],
        ),
        'Waves, sound, and light': (
            'A wave transfers energy without a net transfer of matter. Compare transverse and longitudinal motion, '
            'and use a ray or wavefront diagram to track reflection and refraction.',
            [
                'Wave speed v = fλ, where frequency f is in hertz and wavelength λ is in metres.',
                'For reflection, angle of incidence equals angle of reflection, measured from the normal.',
                'Refraction changes direction when wave speed changes. Refractive index n = c/v; frequency stays constant across a boundary while wavelength changes.',
            ],
            [
                'A wave has frequency 50 Hz and wavelength 0.8 m. Find its speed.',
                'Why does light bend when it enters glass but keep the same frequency?',
                'What is the difference between diffraction and refraction?',
            ],
        ),
        'Electric circuits': (
            'Circuits transfer energy through charges moving in a complete path. Use conventional current direction '
            'from positive to negative, and check whether components are in series or parallel.',
            [
                'Current I = Q/t; potential difference V = E/Q; resistance R = V/I for an ohmic conductor at constant conditions.',
                'Series: current is the same and resistances add. Parallel: potential difference is the same and 1/Rₜ = Σ(1/Rᵢ).',
                'Electrical power P = VI = I²R = V²/R. Electrical energy transferred E = Pt.',
            ],
            [
                'A 12 V supply drives 3 A through a component. Find its resistance and power.',
                'What stays the same across branches in a parallel circuit, and what stays the same in series?',
                'Why might a filament lamp not obey a constant V/I ratio as it heats?',
            ],
        ),
        'Fields and electromagnetism': (
            'A field describes how an object can experience a force without direct contact. Field lines show direction '
            'and relative strength; closer lines indicate a stronger field.',
            [
                'Gravitational field strength g = F/m; electric field strength E = F/q.',
                'A current-carrying wire in a magnetic field experiences a force. For a perpendicular wire, F = BIL.',
                'Electromagnetic induction occurs when magnetic flux linkage changes; a faster change or more coil turns increases induced emf.',
            ],
            [
                'A 2 kg mass experiences a 19.6 N gravitational force. Find the field strength.',
                'Which three quantities determine the force on a wire carrying current in a magnetic field?',
                'Name two ways to increase the induced emf in a coil moving through a magnetic field.',
            ],
        ),
    },
    'chemistry': {
        'Atomic structure and periodicity': (
            'Atoms contain a tiny positive nucleus surrounded by electrons. The proton number identifies the element; '
            'isotopes share proton number but differ in neutron number.',
            [
                'Proton number Z = number of protons; nucleon number A = protons + neutrons; neutrons = A − Z.',
                'For a neutral atom, electrons = protons. Ions form when electrons are lost or gained, while the nucleus remains unchanged in ordinary chemical reactions.',
                'Elements in one group have similar outer-electron arrangements, helping explain recurring chemical properties; trends also depend on nuclear charge and shielding.',
            ],
            [
                'How many protons, neutrons, and electrons are in neutral sodium-23 (Z = 11)?',
                'Why do isotopes of the same element react similarly in most chemical reactions?',
                'How does forming Mg²⁺ change the electron count while leaving the proton count unchanged?',
            ],
        ),
        'Bonding and structure': (
            'Bonding is explained by electrostatic attraction. Connect the particle arrangement and bonding type to '
            'melting point, conductivity, hardness, and solubility.',
            [
                'Ionic bonding is attraction between oppositely charged ions after electron transfer; formula units have an overall charge of zero.',
                'Covalent bonds are shared electron pairs. Simple molecules often have low boiling points because intermolecular forces are weaker than covalent bonds.',
                'Metallic bonding is attraction between positive ions and delocalized electrons, explaining electrical conductivity and malleability.',
            ],
            [
                'Why does solid sodium chloride not conduct electricity, while molten sodium chloride does?',
                'Why can diamond be very hard while graphite conducts electricity, even though both contain carbon?',
                'Which forces must be overcome to boil a simple molecular substance?',
            ],
        ),
        'Equations and stoichiometry': (
            'Balanced equations conserve each type of atom. The mole links particle counts to measurable mass, '
            'allowing reaction quantities to be calculated from equation coefficients.',
            [
                'Moles n = mass m ÷ molar mass M. Number of particles N = nNₐ, where Nₐ ≈ 6.022 × 10²³ mol⁻¹.',
                'For solutions, concentration c = n/V, with V in dm³. Convert cm³ to dm³ by dividing by 1000.',
                'Use the balanced equation’s mole ratio to find the limiting reactant; theoretical yield follows from that reactant, and percentage yield = actual ÷ theoretical × 100%.',
            ],
            [
                'How many moles are in 18 g of water if M(H₂O) = 18 g/mol?',
                'What volume in dm³ is 250 cm³, and why is that conversion important in c = n/V?',
                'If an equation needs 2 mol of A for each 1 mol of B, which reactant limits production when 3 mol A and 2 mol B are available?',
            ],
        ),
        'Acids, bases, and salts': (
            'Acids donate protons in the Brønsted–Lowry model, while bases accept them. Neutralization and titration '
            'calculations use balanced equations and mole ratios.',
            [
                'pH = −log₁₀[H⁺] for hydrogen-ion concentration in mol/dm³; a change of one pH unit means a tenfold change in [H⁺].',
                'Acid + base → salt + water. For a 1:1 reaction, cₐVₐ = cᵦVᵦ at equivalence; use the balanced mole ratio for other reactions.',
                'Strong describes the extent of ionization, while concentrated describes amount per volume; these are different properties.',
            ],
            [
                'A solution has [H⁺] = 1 × 10⁻³ mol/dm³. Find its pH.',
                'Why is a concentrated weak acid not necessarily stronger than a dilute strong acid?',
                'What information does the equivalence point provide in an acid–base titration?',
            ],
        ),
        'Energy, rates, and equilibrium': (
            'Reaction rate depends on successful particle collisions, while equilibrium describes a dynamic balance '
            'in a reversible reaction. Track energy changes and conditions separately.',
            [
                'Rate can be measured as change in concentration ÷ time. Higher temperature, concentration, pressure for gases, or surface area can increase collision frequency or energy.',
                'A catalyst lowers activation energy by providing an alternative pathway; it speeds forward and reverse reactions without changing the equilibrium position.',
                'At dynamic equilibrium, forward and reverse rates are equal. Changing concentration, pressure, or temperature shifts the position to oppose the imposed change.',
            ],
            [
                'Why does powdered calcium carbonate react faster than equal-mass lumps?',
                'What changes and what does not change when a catalyst is added to a system at equilibrium?',
                'For an exothermic forward reaction, predict the effect of increasing temperature on the equilibrium position.',
            ],
        ),
        'Organic chemistry foundations': (
            'Organic chemistry organizes carbon compounds by functional groups and homologous series. Naming and '
            'drawing structures consistently makes reaction patterns easier to recognize.',
            [
                'Alkanes have general formula CₙH₂ₙ₊₂; alkenes with one C=C bond have formula CₙH₂ₙ (for open-chain compounds).',
                'Structural isomers have the same molecular formula but different atom connectivity. A functional group is the part responsible for characteristic reactions.',
                'Combustion of a hydrocarbon produces CO₂ and H₂O in excess oxygen; limited oxygen can produce CO and/or carbon.',
            ],
            [
                'Write the molecular formula for an open-chain alkane with 5 carbon atoms.',
                'How can two molecules share a molecular formula yet have different properties?',
                'Balance the complete combustion equation for methane: CH₄ + O₂ → CO₂ + H₂O.',
            ],
        ),
    },
    'biology': {
        'Cells and transport': (
            'Cell structure supports cell function, while exchange surfaces move substances between cells and their '
            'environment. Transport depends on concentration gradients, membranes, and energy availability.',
            [
                'Diffusion is net particle movement down a concentration gradient; osmosis is net water movement through a partially permeable membrane.',
                'Active transport moves substances against a concentration gradient using energy from respiration and membrane transport proteins.',
                'A larger surface-area-to-volume ratio generally allows faster exchange relative to a cell’s needs; specialization adapts cells for particular functions.',
            ],
            [
                'How does osmosis differ from diffusion of a solute?',
                'Why does active transport require energy when diffusion does not?',
                'Why are many cells small, or arranged into thin exchange surfaces?',
            ],
        ),
        'Metabolism and enzymes': (
            'Metabolism is the sum of chemical reactions in an organism. Enzymes lower activation energy, and their '
            'rate depends on conditions that affect collisions and active-site shape.',
            [
                'Enzyme + substrate ⇌ enzyme–substrate complex → enzyme + product. Enzymes are not used up in the reaction.',
                'Photosynthesis: 6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂ (light and chlorophyll). Aerobic respiration: C₆H₁₂O₆ + 6O₂ → 6CO₂ + 6H₂O + energy.',
                'Temperature, pH, substrate concentration, and enzyme concentration affect rate; extreme pH or heat may alter the active site through denaturation.',
            ],
            [
                'What happens to enzyme activity when temperature rises toward the optimum, and what can happen above it?',
                'Name the reactants and products in the balanced photosynthesis equation.',
                'Why does increasing substrate concentration eventually stop increasing the reaction rate?',
            ],
        ),
        'Genetics and cell division': (
            'Genetic information is stored in DNA and expressed through proteins. Cell division supports growth and '
            'repair, while meiosis produces genetically varied gametes.',
            [
                'A gene is a DNA sequence that contributes to a functional product; alleles are alternative versions of a gene.',
                'Mitosis produces two genetically similar daughter cells with the same chromosome number; meiosis produces four genetically different haploid cells.',
                'For a single-gene cross Aa × Aa with complete dominance, expected genotype ratio is 1 AA : 2 Aa : 1 aa; phenotype ratio is 3 dominant : 1 recessive.',
            ],
            [
                'What is the difference between a gene and an allele?',
                'Why does meiosis reduce chromosome number by half?',
                'For Aa × Aa, what is the probability of an aa offspring under the stated model?',
            ],
        ),
        'Human body systems': (
            'Body systems coordinate exchange, transport, and control. Homeostasis keeps internal conditions within '
            'ranges that allow cells and enzymes to function.',
            [
                'The digestive system breaks large food molecules into absorbable molecules; the small intestine’s villi increase surface area for absorption.',
                'The heart and vessels maintain circulation: arteries carry blood away from the heart, veins return it, and capillaries enable exchange.',
                'Negative feedback detects deviation from a set range and triggers responses that oppose the change, such as temperature regulation.',
            ],
            [
                'How do villi improve nutrient absorption?',
                'Which direction does blood flow in arteries and veins, and what exception makes the oxygen content an unreliable definition?',
                'In negative feedback, how does the response relate to the original change?',
            ],
        ),
        'Evolution and classification': (
            'Evolution is change in inherited characteristics of populations across generations. Classification groups '
            'organisms using shared traits and evidence of evolutionary relationships.',
            [
                'Natural selection requires heritable variation and differences in reproductive success; allele frequencies can change over generations.',
                'Mutations create new genetic variants. Selection acts on phenotypes, while inheritance passes alleles to offspring.',
                'Evidence for common ancestry includes homologous structures, fossils, and molecular similarities; classification is revised when evidence changes.',
            ],
            [
                'What three conditions allow natural selection to change a population?',
                'Why does a mutation not automatically make an organism better adapted?',
                'How can DNA similarity support a proposed evolutionary relationship?',
            ],
        ),
        'Ecology': (
            'Ecology examines interactions among organisms and their environments. Energy flows through ecosystems, '
            'while matter is recycled through nutrient cycles.',
            [
                'Only a fraction of energy transfers between trophic levels; energy is lost through respiration, heat, waste, and uneaten material.',
                'Population change depends on births, deaths, immigration, and emigration. Sampling methods should match the organism and habitat.',
                'Biodiversity includes variety within species, between species, and among ecosystems; conservation aims to protect these levels and ecosystem function.',
            ],
            [
                'Why is less energy available at higher trophic levels?',
                'Which factors can increase or decrease a population between two observations?',
                'How can a random quadrat sample reduce bias when estimating plant abundance?',
            ],
        ),
    },
    'english': {
        'Parts of speech': (
            'Grammar describes how words form phrases and clauses. Identify a word’s role in its sentence rather than '
            'relying only on its usual label, since many words can perform more than one function.',
            [
                'A clause contains a subject and a finite verb; an independent clause can stand alone, while a dependent clause relies on another clause.',
                'A phrase acts as a unit but does not contain a complete subject–finite-verb combination.',
                'Subject–verb agreement follows the grammatical head of the subject: “The list of items is…” because “list” is singular.',
            ],
            [
                'In “The careful student quickly revised the essay,” identify the noun, adjective, adverb, and verb.',
                'What makes a clause independent rather than dependent?',
                'Why is “The box of pencils is full” grammatically singular?',
            ],
        ),
        'Sentence structure': (
            'Sentence structure controls how ideas relate. Punctuation should reflect clause boundaries and meaning, '
            'not simply pauses when reading aloud.',
            [
                'A simple sentence has one independent clause; a compound sentence joins independent clauses; a complex sentence combines an independent and dependent clause.',
                'A comma splice joins independent clauses with only a comma; repair it with a full stop, semicolon, or coordinating conjunction.',
                'Use a colon to introduce an explanation or list after a complete clause; use a semicolon to connect closely related independent clauses.',
            ],
            [
                'Classify “Although it rained, the match continued” and identify its clauses.',
                'Why is “I was late, I missed the bus” a comma splice, and how can it be corrected?',
                'When would a semicolon be more suitable than a comma?',
            ],
        ),
        'Tense and grammar patterns': (
            'Verb forms place events in time and show whether they are ongoing, completed, or viewed from another '
            'time point. Keep tense choices consistent unless the time relationship changes.',
            [
                'Present perfect = have/has + past participle; it links a past event to the present, as in “She has finished.”',
                'Past perfect = had + past participle; it marks an event earlier than another past event.',
                'Use modal verbs such as might, must, and should to express possibility, necessity, and advice; the main verb normally stays in its base form.',
            ],
            [
                'What difference in time or meaning is suggested by “I lived there” and “I have lived there”?',
                'Why might a writer use past perfect in “The train had left before we arrived”?',
                'Correct “She might goes tomorrow” and explain the verb form.',
            ],
        ),
        'Vocabulary in context': (
            'Word meaning comes from both context and word structure. Roots, prefixes, and suffixes can reveal a '
            'likely meaning, but check the sentence because meanings can shift by context.',
            [
                'A prefix changes or qualifies a base (for example, re- suggests again); a suffix can change a word’s grammatical class (teach → teacher).',
                'Use nearby definitions, examples, contrasts, and cause–effect clues to infer an unfamiliar word.',
                'Collocations are words that commonly occur together; learning “make a decision” as a phrase can improve accuracy and fluency.',
            ],
            [
                'Use the prefix and context to infer the meaning of “misinterpret.”',
                'Which clue types could help infer an unknown word without a dictionary?',
                'Why is “make a decision” more idiomatic than “do a decision”?',
            ],
        ),
        'Reading analysis': (
            'A strong reading response separates what a text states from what can be inferred. Support interpretations '
            'with precise evidence and explain how the evidence creates meaning.',
            [
                'An inference combines textual evidence with reasoning; it should be plausible and traceable to specific details.',
                'Tone is the writer’s attitude, while mood is the feeling created for a reader. Diction, imagery, syntax, and detail can shape both.',
                'Evaluate purpose and audience by considering what the text emphasizes, omits, and asks its readers to believe or do.',
            ],
            [
                'What evidence supports an inference about a character’s motivation?',
                'How can diction create a tone of uncertainty without explicitly saying “I am uncertain”?',
                'What is one difference between a text’s purpose and its topic?',
            ],
        ),
        'Essay construction': (
            'An effective essay makes a focused claim and develops it through relevant evidence and reasoning. '
            'Each paragraph should contribute to the argument rather than merely repeat information.',
            [
                'A thesis answers the question with a defensible claim and previews the main line of reasoning.',
                'A useful paragraph pattern is claim → evidence → explanation → link; explanation should show why the evidence supports the claim.',
                'Revision checks argument and structure first, then sentence clarity, grammar, and punctuation.',
            ],
            [
                'How does a thesis differ from a topic statement?',
                'After presenting a quotation, what should the explanation do?',
                'Why is it efficient to revise an essay’s argument before proofreading commas?',
            ],
        ),
    },
    'history': {
        'Chronology and periodization': (
            'Chronology orders events, while periodization groups time into meaningful phases. Historical boundaries '
            'are useful interpretations and may differ depending on the region or question.',
            [
                'A timeline distinguishes sequence from causation: an event occurring earlier does not alone prove it caused a later event.',
                'Continuity describes what persists; change describes what is transformed. Both can occur at different speeds and across different groups.',
                'A turning point is a moment that substantially redirects later developments, assessed by its consequences rather than its dramatic appearance.',
            ],
            [
                'Why does “after this, therefore because of this” fail as a causal argument?',
                'Give an example of continuity and change occurring at the same time.',
                'What evidence would help decide whether an event was a turning point?',
            ],
        ),
        'Sources and evidence': (
            'Sources are evidence to analyze, not simply facts to accept. Their value depends on the question, the '
            'creator’s context, and what the source can reliably reveal.',
            [
                'Assess origin, purpose, and context; consider intended audience, incentives, access to information, and limitations.',
                'Corroboration compares independent sources. Agreement can increase confidence, while disagreement may reveal perspective or changing circumstances.',
                'A source can be useful even when biased: bias affects how it should be interpreted, not whether it contains any evidence.',
            ],
            [
                'What can a private letter reveal that an official speech may not, and what might each omit?',
                'Why does comparing independent sources strengthen an interpretation?',
                'How can a biased source still be useful to a historian?',
            ],
        ),
        'Cause and consequence': (
            'Historical outcomes usually have multiple causes operating over different time scales. Separate long-term '
            'conditions from triggers, and distinguish intended consequences from unintended ones.',
            [
                'A causal explanation weighs structural conditions, decisions, immediate triggers, and chance rather than listing factors without relationships.',
                'Use counterfactual reasoning cautiously: ask whether the outcome might have differed without one factor, while acknowledging uncertainty.',
                'Consequences can be political, economic, social, or cultural and may affect groups differently over short and long periods.',
            ],
            [
                'How does a long-term cause differ from an immediate trigger?',
                'Why should a causal essay explain the relative importance of factors?',
                'How could the same event produce different consequences for different groups?',
            ],
        ),
        'Empires and states': (
            'States build authority through institutions, resources, and claims to legitimacy. Expansion can bring '
            'wealth and influence while also creating resistance and administrative strain.',
            [
                'Legitimacy is the accepted right to rule; it may draw on law, tradition, religion, elections, or performance.',
                'Centralization can improve coordination but may weaken local autonomy; compare the state’s formal authority with its actual capacity.',
                'Resistance can be political, cultural, economic, or armed and may reshape policies even when it does not overthrow a state.',
            ],
            [
                'What is the difference between possessing authority and having legitimacy?',
                'Why can an expanding empire become harder to govern?',
                'What forms can resistance take besides armed rebellion?',
            ],
        ),
        'Revolutions and industrialization': (
            'Revolutions and industrialization emerge from interacting ideas, institutions, resources, and social '
            'pressures. Examine who benefited, who bore costs, and how change spread.',
            [
                'Industrialization changes production through technology, energy use, capital, labor organization, and transport.',
                'Revolutionary change may alter political authority while social and economic structures persist, so measure change across several dimensions.',
                'Urbanization can expand employment and services while producing overcrowding, pollution, and unequal living conditions.',
            ],
            [
                'How might a new transport technology change both production and migration?',
                'Why should a revolution’s success be judged beyond whether a ruler was replaced?',
                'Name one benefit and one cost urbanization could create for workers.',
            ],
        ),
        'Modern conflicts and cooperation': (
            'Modern international history includes competition and attempts to manage shared problems. Analyze '
            'ideology, security, resources, institutions, and local agency together.',
            [
                'Nationalism links political identity to a nation and can support self-determination or exclusionary state projects.',
                'Decolonization varied by place; negotiation, mass movements, international pressure, and armed conflict all shaped outcomes.',
                'International institutions coordinate rules and cooperation, but their influence depends on member states, resources, and enforcement.',
            ],
            [
                'How can nationalism support both independence and exclusion?',
                'Why did decolonization take different forms in different regions?',
                'What limits the ability of an international organization to enforce its decisions?',
            ],
        ),
    },
    'geography': {
        'Earth structure and landforms': (
            'Earth’s surface is reshaped by internal forces and external processes. Link the process, timescale, '
            'materials, and conditions to the landform being explained.',
            [
                'At constructive boundaries plates move apart; at destructive boundaries one may subduct; at conservative boundaries they slide past.',
                'Weathering breaks rock in place, erosion removes and transports material, and deposition lays it down when transport energy falls.',
                'River energy and sediment load change downstream; hydraulic action, abrasion, attrition, and solution are distinct erosion processes.',
            ],
            [
                'How does a destructive plate boundary differ from a conservative one?',
                'Distinguish weathering from erosion using a simple example.',
                'Why might a river deposit sediment when it enters a lake?',
            ],
        ),
        'Weather and climate': (
            'Weather describes short-term atmospheric conditions; climate summarizes patterns over long periods. '
            'Explain climate using energy balance, circulation, water, and geographic controls.',
            [
                'Air pressure differences create pressure gradients that drive winds; Earth’s rotation deflects large-scale flow.',
                'The water cycle transfers water by evaporation, condensation, precipitation, infiltration, and runoff.',
                'Latitude, altitude, distance from oceans, ocean currents, and relief influence temperature and precipitation patterns.',
            ],
            [
                'How is a climate average different from a weather observation?',
                'Why does temperature generally decrease with altitude in the troposphere?',
                'How can a mountain create a rain shadow?',
            ],
        ),
        'Ecosystems and resources': (
            'Ecosystems connect organisms, energy, and physical conditions. Resource management balances ecological '
            'limits with social needs over time.',
            [
                'Energy enters many ecosystems as sunlight, moves through producers and consumers, and is dissipated as heat.',
                'Nutrient cycles move matter between organisms, soil, water, and atmosphere; unlike energy, matter is recycled.',
                'Sustainable management considers renewal rate, demand, access, ecosystem effects, and the needs of future users.',
            ],
            [
                'Why is energy flow through an ecosystem one-way while nutrients cycle?',
                'What could happen if a renewable resource is used faster than it can regenerate?',
                'How might conservation and local livelihoods be balanced?',
            ],
        ),
        'Population and migration': (
            'Population patterns reflect births, deaths, and movement. Migration decisions combine pressures and '
            'attractions with personal resources, routes, policies, and constraints.',
            [
                'Population change = births − deaths + immigration − emigration over the same period.',
                'A population pyramid shows age and sex structure; its shape suggests past fertility, mortality, migration, and future service needs.',
                'Push–pull factors help organize migration explanations, but decisions are rarely caused by one factor alone.',
            ],
            [
                'A place has 900 births, 600 deaths, 120 immigrants, and 200 emigrants in a year. What is its net change?',
                'What service pressures might a wide base on a population pyramid suggest?',
                'Why might two people facing the same push factor make different migration choices?',
            ],
        ),
        'Cities and development': (
            'Urban areas concentrate people and activity, creating both opportunities and unequal access to space '
            'and services. Use evidence at neighborhood as well as city scale.',
            [
                'Urbanization is the rising share of people living in urban places; it may result from natural increase and rural-to-urban migration.',
                'Land-use patterns reflect accessibility, land value, planning, and historical development.',
                'Development indicators such as income, life expectancy, and education each measure different dimensions and can hide inequality.',
            ],
            [
                'How does urbanization differ from city population growth?',
                'Why might land near a transport hub be more valuable?',
                'What limitation arises when using only national average income to compare development?',
            ],
        ),
        'Globalization and economies': (
            'Globalization links production, finance, information, and people across places. These connections can '
            'create efficiency and opportunity while distributing costs and benefits unevenly.',
            [
                'A supply chain links inputs, production, transport, sales, and consumers across locations.',
                'Comparative advantage concerns lower opportunity cost, not necessarily absolute productivity.',
                'Transport and communication changes can increase interdependence, while shocks reveal vulnerabilities in connected systems.',
            ],
            [
                'What is one way a product’s supply chain can span several countries?',
                'How does comparative advantage differ from absolute advantage?',
                'Why can global connections spread both opportunities and disruptions?',
            ],
        ),
    },
    'computer-science': {
        'Data representation': (
            'Computers represent information with patterns of bits. A representation determines range, precision, '
            'file size, and what information may be lost.',
            [
                'Binary place values are powers of two. Hexadecimal uses digits 0–9 and A–F, with one hex digit representing four bits.',
                'For an unsigned n-bit integer, the range is 0 to 2ⁿ − 1. Signed two’s-complement n-bit values range from −2ⁿ⁻¹ to 2ⁿ⁻¹ − 1.',
                'Sampling rate and bit depth affect digital audio size and quality; lossy compression discards information, while lossless compression preserves it.',
            ],
            [
                'What is the unsigned range of an 8-bit integer?',
                'How many bits are represented by three hexadecimal digits?',
                'What is the trade-off between a higher audio sampling rate and file size?',
            ],
        ),
        'Algorithms and complexity': (
            'An algorithm is a precise sequence of steps that solves a class of problems. Correctness, termination, '
            'and resource use matter alongside the final result.',
            [
                'Linear search checks up to n items; binary search takes about log₂n comparisons but requires sorted data.',
                'Big-O describes growth as input size increases: a single loop is often O(n), nested loops often O(n²), and halving a search space gives O(log n).',
                'Test normal, boundary, and invalid inputs. An algorithm should handle empty collections and repeated values when those are possible.',
            ],
            [
                'Why can binary search not be safely used on an unsorted list?',
                'How does doubling n affect a linear algorithm compared with a quadratic one?',
                'What boundary tests would you use for a function that accepts values from 1 to 100?',
            ],
        ),
        'Hardware and architecture': (
            'A computer executes instructions by moving data between storage, memory, and processor components. '
            'Performance depends on workload and bottlenecks, not clock speed alone.',
            [
                'The fetch–decode–execute cycle retrieves an instruction, interprets it, and carries out the operation.',
                'RAM is volatile working memory; secondary storage is non-volatile and retains data without power.',
                'A CPU includes an arithmetic logic unit, control unit, and registers; cache reduces average access time for frequently used data.',
            ],
            [
                'What happens during each stage of the fetch–decode–execute cycle?',
                'Why is RAM not a substitute for long-term storage?',
                'How can cache improve performance without replacing main memory?',
            ],
        ),
        'Programming constructs': (
            'Programs combine data, decisions, repetition, and reusable operations. Clear types and validation reduce '
            'errors, while tests check behavior across expected and unexpected cases.',
            [
                'Sequence runs statements in order; selection branches on a condition; iteration repeats a block while a count or condition requires it.',
                'A function should have a clear purpose, defined inputs, and predictable outputs; local variables limit unintended side effects.',
                'Validate inputs at system boundaries and test typical, boundary, and invalid cases.',
            ],
            [
                'When is a while loop more suitable than a for loop?',
                'Why can passing data into a function be safer than relying on global state?',
                'What tests would check a function that calculates the average of a list?',
            ],
        ),
        'Data structures and databases': (
            'Data structures organize information for particular operations. Database design represents entities '
            'and relationships while reducing duplication and preserving consistency.',
            [
                'A stack is last-in, first-out; a queue is first-in, first-out. Choose according to the order the task needs.',
                'A relational table uses rows for records and columns for attributes; a primary key identifies a row and a foreign key links related rows.',
                'Normalization separates repeated facts into related tables; queries select, filter, join, and aggregate records.',
            ],
            [
                'Which structure models a printer queue, and why?',
                'How does a foreign key connect two tables?',
                'What kind of data duplication can normalization reduce?',
            ],
        ),
        'Networks and cybersecurity': (
            'Networks move data according to shared protocols. Security protects confidentiality, integrity, and '
            'availability through technical controls and careful user practices.',
            [
                'An IP address identifies a network interface for routing; DNS translates human-readable domain names into address records.',
                'Encryption protects data using keys; authentication verifies identity, while authorization determines permitted actions.',
                'Defense in depth combines controls such as updates, least privilege, backups, filtering, and monitoring.',
            ],
            [
                'What role does DNS play when a user opens a website?',
                'How are authentication and authorization different?',
                'Why are backups useful even when encryption and access controls are in place?',
            ],
        ),
    },
    'medicine': {
        'Anatomical language': (
            'Anatomical terms provide a consistent map of the body. Describe position relative to a standard '
            'anatomical position and name the plane or region when it clarifies the location.',
            [
                'Anatomical position is upright, facing forward, arms at the sides, and palms forward; left and right refer to the subject.',
                'Sagittal divides left and right, coronal (frontal) divides front and back, and transverse divides upper and lower portions.',
                'Proximal means nearer the point of attachment; distal means farther away. Medial is nearer the midline; lateral is farther from it.',
            ],
            [
                'Which plane divides the body into anterior and posterior portions?',
                'In anatomical language, whose left side is meant?',
                'Is the wrist proximal or distal to the elbow?',
            ],
        ),
        'Physiology and homeostasis': (
            'Physiology explains how body systems maintain function. Homeostasis uses sensors, control centers, and '
            'effectors to keep variables within workable ranges.',
            [
                'Negative feedback reduces the initial deviation; positive feedback amplifies a process until a specific endpoint.',
                'A control loop can be described as stimulus → receptor → coordinator → effector → response.',
                'Temperature and glucose regulation are examples of variables controlled around a range, not held at a perfectly unchanging value.',
            ],
            [
                'What are the roles of receptor, coordinator, and effector in a feedback loop?',
                'How does negative feedback differ from positive feedback?',
                'Why is homeostasis better described as maintaining a range than an exact fixed value?',
            ],
        ),
        'Pathology foundations': (
            'Pathology studies disease processes and their effects on tissues. Separate cause, mechanism, structural '
            'change, symptoms, and outcomes when describing a condition.',
            [
                'Etiology is the cause; pathogenesis is the process by which disease develops; manifestations are signs and symptoms.',
                'Inflammation is a coordinated response to injury or infection and can be acute or chronic.',
                'A risk factor changes probability but does not guarantee an outcome; association alone does not prove causation.',
            ],
            [
                'How does etiology differ from pathogenesis?',
                'What is the difference between a sign observed by an examiner and a symptom reported by a patient?',
                'Why does a risk factor not mean that every exposed person develops disease?',
            ],
        ),
        'History and examination': (
            'Clinical assessment gathers a structured account of concerns and relevant context. Clear documentation '
            'distinguishes patient-reported information from observed findings.',
            [
                'A focused history explores the presenting concern, timeline, associated features, relevant medical history, medicines, and allergies.',
                'Vital signs and examination findings are observations; record values, units, timing, and relevant conditions.',
                'Use open questions first, then focused questions to clarify details without leading the patient.',
            ],
            [
                'Why should a clinician establish the timeline of a presenting concern?',
                'How is a patient-reported symptom different from an examination finding?',
                'What is the risk of beginning with a leading question?',
            ],
        ),
        'Diagnostics and reasoning': (
            'Clinical reasoning updates possible explanations as evidence arrives. Tests provide information with '
            'limits, and results must be interpreted in context.',
            [
                'Sensitivity = true positives/(true positives + false negatives); specificity = true negatives/(true negatives + false positives).',
                'Positive predictive value depends on both test performance and the condition’s prevalence in the tested population.',
                'A differential diagnosis is a ranked set of explanations; revise it when new findings change their relative likelihood.',
            ],
            [
                'What does high sensitivity mean about false negatives?',
                'Why can a positive result be less informative when a condition is rare?',
                'What should happen to a differential diagnosis when new evidence conflicts with the leading explanation?',
            ],
        ),
        'Pharmacology principles': (
            'Pharmacology links drug concentration to biological effects. The route, dose, patient factors, and '
            'interactions influence response and safety.',
            [
                'Pharmacokinetics is often summarized as ADME: absorption, distribution, metabolism, and excretion.',
                'A loading dose may rapidly reach a target concentration; maintenance dosing replaces drug eliminated over time.',
                'Dose response varies among people. Check therapeutic range, contraindications, interactions, and monitoring requirements.',
            ],
            [
                'What does each letter in ADME represent?',
                'Why might a loading dose be used before maintenance doses?',
                'Why can the same dose produce different effects in different patients?',
            ],
        ),
    },
    'law': {
        'Sources of law': (
            'Legal systems draw rules from multiple authorities, whose rank and effect depend on jurisdiction. '
            'Always identify which source controls the question being analyzed.',
            [
                'A constitution can establish institutions, rights, and limits on public power; statutes are enacted by a legislature.',
                'Regulations are made under authority delegated by legislation; courts interpret and apply legal rules in cases.',
                'Precedent may bind lower courts within a hierarchy, while persuasive decisions can inform but not control a result.',
            ],
            [
                'How does delegated legislation differ from an act passed by a legislature?',
                'What makes a precedent binding rather than merely persuasive?',
                'Why does jurisdiction matter before applying a legal rule?',
            ],
        ),
        'Courts and procedure': (
            'Procedure determines how a dispute is brought, evidence is assessed, and decisions may be reviewed. '
            'The applicable process depends on the court and type of case.',
            [
                'Jurisdiction concerns a court’s authority over the subject matter, parties, or geographic area.',
                'The burden of proof identifies who must establish a claim; the standard describes how convincing the evidence must be.',
                'An appeal generally reviews claimed legal or procedural error under applicable rules rather than automatically retrying every fact.',
            ],
            [
                'How are burden of proof and standard of proof different?',
                'What does jurisdiction determine?',
                'Why is an appeal not always a complete retrial?',
            ],
        ),
        'Legal reasoning': (
            'Legal reasoning applies rules to facts while explaining both the conclusion and its limits. A transparent '
            'structure helps readers see where interpretation or uncertainty enters.',
            [
                'IRAC: identify the Issue, state the Rule, Apply it to the facts, and reach a Conclusion.',
                'Distinguish a material fact, which can affect the rule’s application, from a background detail that does not change the analysis.',
                'Use precedent by identifying the rule, comparing material facts, and explaining meaningful distinctions.',
            ],
            [
                'What should the Application part of IRAC do beyond restating the rule?',
                'How can a court distinguish an earlier case?',
                'Why can two cases with the same broad topic have different outcomes?',
            ],
        ),
        'Contract and tort': (
            'Contract law focuses on enforceable agreements; tort law addresses civil wrongs and remedies. Identify '
            'the elements before deciding whether facts satisfy a claim.',
            [
                'A contract analysis commonly considers offer, acceptance, consideration, intention, and applicable capacity or form requirements.',
                'Negligence generally requires duty, breach, causation, and legally recognized damage; each element needs supporting facts.',
                'Causation often asks both factual connection and whether the loss is sufficiently linked under the jurisdiction’s legal test.',
            ],
            [
                'Why is an invitation to negotiate not always an offer?',
                'What elements are commonly required to establish negligence?',
                'How can factual causation differ from legal or proximate causation?',
            ],
        ),
        'Criminal law': (
            'Criminal liability usually requires a prohibited act and a required mental state, subject to defenses '
            'and jurisdiction-specific rules.',
            [
                'Actus reus describes the prohibited conduct or result; mens rea describes the required mental state.',
                'The prosecution generally must prove each required element to the applicable criminal standard.',
                'Defenses may negate an element or provide a justification or excuse; their availability and burden vary by jurisdiction.',
            ],
            [
                'Why are actus reus and mens rea analyzed separately?',
                'How can a defense challenge liability even when the conduct occurred?',
                'Why should an answer identify the jurisdiction before stating a criminal rule?',
            ],
        ),
        'Public and constitutional law': (
            'Public law governs the exercise of state power. Constitutional structures and review mechanisms aim '
            'to make authority lawful, accountable, and consistent with protected rights.',
            [
                'Separation of powers allocates functions among branches; checks and balances limit concentration of authority.',
                'Judicial review examines whether a public decision-maker acted within legal powers and followed required procedures.',
                'Rights analysis identifies the protected interest, the government action, the applicable test, and any permitted limitation.',
            ],
            [
                'What problem is separation of powers intended to reduce?',
                'How does judicial review differ from deciding whether a policy is wise?',
                'What questions should be asked before concluding that a right was unlawfully restricted?',
            ],
        ),
    },
}


def enrich_catalog(apps, schema_editor):
    Subject = apps.get_model('catalog', 'Subject')
    ReviewBlock = apps.get_model('catalog', 'ReviewBlock')
    for slug, topics in CONTENT.items():
        subject = Subject.objects.filter(slug=slug).first()
        if subject is None:
            continue
        for title, (summary, key_points, recall_prompts) in topics.items():
            ReviewBlock.objects.filter(part__subject=subject, title=title).update(
                summary=summary,
                key_points='\n'.join(key_points),
                recall_prompts='\n'.join(recall_prompts),
            )


class Migration(migrations.Migration):
    dependencies = [('catalog', '0002_seed_catalog')]
    operations = [migrations.RunPython(enrich_catalog, migrations.RunPython.noop)]
