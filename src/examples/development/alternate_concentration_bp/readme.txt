This was generated during the call, with no intention to be distributed,so it 
is not optimal as an example. 

To view it, checkout a version of OBI and replace obi.owl with this file, or 
open this file and add a 'local folder' containing the /trunk/src/ontology 
folder as a repository, with 'include subfolders' enabled. 

The textual description may be better. Here is the original email. The owl 
differs in so far as that has_part was replaced with has_component, following
Alan's feedback. 
 

Portion of Liquid is_a Ensemble of granular parts (Molecules and Free Atoms) that has quality liquid.
Component of Portion of Liquid  -  An Ensemble of granular parts (molecules and Free Atoms) that is part_of a Portion of Liquid and has a concentration towards the whole

50%_concentration_by_mass is_a concentration is_a quality

Tris Buffer is a Portion of Liquid
has_part (Component of Portion of Liquid and has_granular part only Tris and has_quality 1%_concentration_by_mass)
has_part (Component of Portion of Liquid and has_granular part only H20 and has_quality 99%_concentration_by_mass)

Other nice things about components of: solute and solvent apply to components of portions, never portions. 