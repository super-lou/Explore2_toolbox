# 1. AVANT PROPOS ___________________________________________________
## 1.1. La cohérence croisée ________________________________________
La mise en place d’un double niveau d’information (éléments du nom
du fichier et métadonnées) nécessite de contrôler la cohérence entre
les deux, mais est primordiale car contribue à la qualité du jeu de
données. Tout comme la standardisation des unités et des noms est
primordiale pour éviter les confusions et simplifier le traitement
des données par les utilisateurs.


Exemple de variables hydrologiques :

----------+--------+-------------------------+-------+-------------
Accronyme | Name   | Long name               | Units | Cell methods
----------+--------+-------------------------+-------+-------------
debit      debit    Debit Modcou              m3.s-1  time:sum
DRAINC     DRAINC   Drainage for tile nature  mm      time:sum
EVAPC      EVAPC    Evapotranspiration        mm      time:sum
RUNOFFC    RUNOFFC  Runoff for tile nature    mm      time:sum
SWE        SWE      Snow Water Equivalent     mm      time:mean ?
SWI        SWI      Soil Water Index          -       time:mean ?
----------+--------+-------------------------+-------+-------------

Voir aussi :
CF Standard Name Table = http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
IPCC Standard Output from Coupled Ocean-Atmosphere GCMs = https://pcmdi.llnl.gov/mips/cmip3/variableList.html
CMIP5-CMOR-Tables = https://wcrp-cmip.github.io/WGCM_Infrastructure_Panel//cmor_and_mip_tables.html
Data Reference Syntax (DRS) for bias-adjusted CORDEX = http://is-enes-data.github.io/CORDEX_adjust_drs.pdf 
