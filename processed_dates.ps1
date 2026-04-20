# ======================================================

# Script Name: Processed_Dates_Master.ps1

# Purpose:

#   Master dashboard showing latest processed activity

#   per county for dashboarding.

# ======================================================

 

# -------------------------

# PATHS

# -------------------------

$BasePath  = \\piftp1.pi.local\ftp$\Counties

$ExcelPath = \\flmaipiqnas01\Imaging5\QC Requests\Kurtis\Dashboard\Processed_Dates_Dashboard.xlsx

 

# Ensure output directory exists

$ExcelDir = Split-Path $ExcelPath -Parent

if (-not (Test-Path $ExcelDir)) {

    New-Item -ItemType Directory -Path $ExcelDir -Force | Out-Null

}

 

# ------------------------------------------------------

# COUNTY DEFINITIONS

# NOTE: Folder is derived automatically as "<State>-<County>"

# ------------------------------------------------------

$Counties = @(

    # ===== ALABAMA =====

    @{ State="AL"; SUBCODE="ALBALD"; County="Baldwin" }

    @{ State="AL"; SUBCODE="ALMADI"; County="Madison" }

    @{ State="AL"; SUBCODE="ALMOBI"; County="Mobile" }

    @{ State="AL"; SUBCODE="ALSHEL"; County="Shelby" }

 

    # ===== ARKANSAS =====

    @{ State="AR"; SUBCODE="ARBENT"; County="Benton" }

    @{ State="AR"; SUBCODE="ARGREE"; County="Greene" }

    @{ State="AR"; SUBCODE="ARWHIT"; County="White" }

 

    # ===== ARIZONA =====

    @{ State="AZ"; SUBCODE="AZAPAC"; County="Apache" }

    @{ State="AZ"; SUBCODE="AZCOCO"; County="Coconino" }

    @{ State="AZ"; SUBCODE="AZGILA"; County="Gila" }

    @{ State="AZ"; SUBCODE="AZGRAH"; County="Graham" }

    @{ State="AZ"; SUBCODE="AZGREE"; County="Greenlee" }

    @{ State="AZ"; SUBCODE="AZLAPA"; County="La Paz" }

    @{ State="AZ"; SUBCODE="MP"; County="Maricopa" }

    @{ State="AZ"; SUBCODE="MV"; County="Mohave" }

    @{ State="AZ"; SUBCODE="AZNAVA"; County="Navajo" }

    @{ State="AZ"; SUBCODE="AZPIMA"; County="Pima" }

    @{ State="AZ"; SUBCODE="PL"; County="Pinal" }

    @{ State="AZ"; SUBCODE="AZYAVA"; County="Yavapai" }

    @{ State="AZ"; SUBCODE="AZYUMA"; County="Yuma" }

 

    # ===== CALIFORNIA =====

    @{ State="CA"; SUBCODE="CAALAM"; County="Alameda" }

    @{ State="CA"; SUBCODE="CABUTT"; County="Butte" }

    @{ State="CA"; SUBCODE="CACOLU"; County="Colusa" }

    @{ State="CA"; SUBCODE="CACONT"; County="Contra Costa" }

    @{ State="CA"; SUBCODE="CAELDO"; County="El Dorado" }

    @{ State="CA"; SUBCODE="FR"; County="Fresno" }

    @{ State="CA"; SUBCODE="CAGLEN"; County="Glenn" }

    @{ State="CA"; SUBCODE="CAHUMB"; County="Humboldt" }

    @{ State="CA"; SUBCODE="IM"; County="Imperial" }

    @{ State="CA"; SUBCODE="CAINYO"; County="Inyo" }

    @{ State="CA"; SUBCODE="KN"; County="Kern" }

    @{ State="CA"; SUBCODE="KG"; County="Kings" }

    @{ State="CA"; SUBCODE="CALAKE"; County="Lake" }

    @{ State="CA"; SUBCODE="CALASS"; County="Lassen" }

    @{ State="CA"; SUBCODE="CALOSA"; County="Los Angeles" }

    @{ State="CA"; SUBCODE="MA"; County="Madera" }

    @{ State="CA"; SUBCODE="CAMARI"; County="Marin" }

    @{ State="CA"; SUBCODE="CAMEND"; County="Mendocino" }

    @{ State="CA"; SUBCODE="CAMERC"; County="Merced" }

    @{ State="CA"; SUBCODE="CAMONT"; County="Monterey" }

    @{ State="CA"; SUBCODE="CANAPA"; County="Napa" }

    @{ State="CA"; SUBCODE="CANEVA"; County="Nevada" }

    @{ State="CA"; SUBCODE="OR"; County="Orange" }

    @{ State="CA"; SUBCODE="CAPLAC"; County="Placer" }

    @{ State="CA"; SUBCODE="PU"; County="Plumas" }

    @{ State="CA"; SUBCODE="RV"; County="Riverside" }

    @{ State="CA"; SUBCODE="CASACR"; County="Sacramento" }

    @{ State="CA"; SUBCODE="ST"; County="San Benito" }

    @{ State="CA"; SUBCODE="SB"; County="San Bernardino" }

    @{ State="CA"; SUBCODE="SD"; County="San Diego" }

    @{ State="CA"; SUBCODE="CASFRA"; County="San Francisco" }

    @{ State="CA"; SUBCODE="CASANJ"; County="San Joaquin" }

    @{ State="CA"; SUBCODE="CASANL"; County="San Luis Obispo" }

    @{ State="CA"; SUBCODE="CASANM"; County="San Mateo" }

    @{ State="CA"; SUBCODE="CASANT"; County="Santa Barbara" }

    @{ State="CA"; SUBCODE="CASCLR"; County="Santa Clara" }

    @{ State="CA"; SUBCODE="CASCRZ"; County="Santa Cruz" }

    @{ State="CA"; SUBCODE="CASHAS"; County="Shasta" }

    @{ State="CA"; SUBCODE="CASOLA"; County="Solano" }

    @{ State="CA"; SUBCODE="CASONO"; County="Sonoma" }

    @{ State="CA"; SUBCODE="CASTAN"; County="Stanislaus" }

    @{ State="CA"; SUBCODE="CASUTT"; County="Sutter" }

    @{ State="CA"; SUBCODE="CATEHA"; County="Tehama" }

    @{ State="CA"; SUBCODE="TU"; County="Tulare" }

    @{ State="CA"; SUBCODE="CATUOL"; County="Tuolumne" }

    @{ State="CA"; SUBCODE="VN"; County="Ventura" }

    @{ State="CA"; SUBCODE="CAYOLO"; County="Yolo" }

    @{ State="CA"; SUBCODE="CAYUBA"; County="Yuba" }

 

    # ===== COLORADO =====

    @{ State="CO"; SUBCODE="COADAM"; County="Adams" }

    @{ State="CO"; SUBCODE="COARAP"; County="Arapahoe" }

    @{ State="CO"; SUBCODE="COBOUL"; County="Boulder" }

    @{ State="CO"; SUBCODE="COBROO"; County="Broomfield" }

    @{ State="CO"; SUBCODE="COCLEA"; County="Clear Creek" }

    @{ State="CO"; SUBCODE="COCUST"; County="Custer" }

    @{ State="CO"; SUBCODE="CODELT"; County="Delta" }

    @{ State="CO"; SUBCODE="CODENV"; County="Denver" }

    @{ State="CO"; SUBCODE="CODOUG"; County="Douglas" }

    @{ State="CO"; SUBCODE="COEAGL"; County="Eagle" }

    @{ State="CO"; SUBCODE="COELPA"; County="El Paso" }

    @{ State="CO"; SUBCODE="COELBE"; County="Elbert" }

    @{ State="CO"; SUBCODE="COFREM"; County="Fremont" }

    @{ State="CO"; SUBCODE="COGARF"; County="Garfield" }

    @{ State="CO"; SUBCODE="COGUNN"; County="Gunnison" }

    @{ State="CO"; SUBCODE="COJACK"; County="Jackson" }

    @{ State="CO"; SUBCODE="COJEFF"; County="Jefferson" }

    @{ State="CO"; SUBCODE="COLARI"; County="Larimer" }

    @{ State="CO"; SUBCODE="COMESA"; County="Mesa" }

    @{ State="CO"; SUBCODE="COMNTR"; County="Montrose" }

    @{ State="CO"; SUBCODE="COOURA"; County="Ouray" }

    @{ State="CO"; SUBCODE="COPARK"; County="Park" }

    @{ State="CO"; SUBCODE="COPUEB"; County="Pueblo" }

    @{ State="CO"; SUBCODE="COROUT"; County="Routt" }

    @{ State="CO"; SUBCODE="COSANM"; County="San Miguel" }

    @{ State="CO"; SUBCODE="COSUMM"; County="Summit" }

    @{ State="CO"; SUBCODE="COTELL"; County="Teller" }

    @{ State="CO"; SUBCODE="COWELD"; County="Weld" }

    # ===== FLORIDA =====

    @{ State="FL"; SUBCODE="FLALAC"; County="Alachua" }

    @{ State="FL"; SUBCODE="FLBAKE"; County="Baker" }

    @{ State="FL"; SUBCODE="FLBAYX"; County="Bay" }

    @{ State="FL"; SUBCODE="FLBRAD"; County="Bradford" }

    @{ State="FL"; SUBCODE="FLBREV"; County="Brevard" }

    @{ State="FL"; SUBCODE="FLBROW"; County="Broward" }

    @{ State="FL"; SUBCODE="FLCALH"; County="Calhoun" }

    @{ State="FL"; SUBCODE="FLCHAR"; County="Charlotte" }

    @{ State="FL"; SUBCODE="FLCITR"; County="Citrus" }

    @{ State="FL"; SUBCODE="FLCLAY"; County="Clay" }

    @{ State="FL"; SUBCODE="FLCOLL"; County="Collier" }

    @{ State="FL"; SUBCODE="FLCOLU"; County="Columbia" }

    @{ State="FL"; SUBCODE="FLDADE"; County="Dade" }

    @{ State="FL"; SUBCODE="FLDESO"; County="DeSoto" }

    @{ State="FL"; SUBCODE="FLDIXI"; County="Dixie" }

    @{ State="FL"; SUBCODE="FLDUVA"; County="Duval" }

    @{ State="FL"; SUBCODE="FLESCA"; County="Escambia" }

    @{ State="FL"; SUBCODE="FLFLAG"; County="Flagler" }

    @{ State="FL"; SUBCODE="FLFRAN"; County="Franklin" }

    @{ State="FL"; SUBCODE="FLGADS"; County="Gadsden" }

    @{ State="FL"; SUBCODE="FLGILC"; County="Gilchrist" }

    @{ State="FL"; SUBCODE="FLGLAD"; County="Glades" }

    @{ State="FL"; SUBCODE="FLGULF"; County="Gulf" }

    @{ State="FL"; SUBCODE="FLHAMI"; County="Hamilton" }

    @{ State="FL"; SUBCODE="FLHARD"; County="Hardee" }

    @{ State="FL"; SUBCODE="FLHEND"; County="Hendry" }

    @{ State="FL"; SUBCODE="FLHERN"; County="Hernando" }

    @{ State="FL"; SUBCODE="FLHIGH"; County="Highlands" }

    @{ State="FL"; SUBCODE="FLHILL"; County="Hillsborough" }

    @{ State="FL"; SUBCODE="FLHOLM"; County="Holmes" }

    @{ State="FL"; SUBCODE="FLINDI"; County="Indian River" }

    @{ State="FL"; SUBCODE="FLJACK"; County="Jackson" }

    @{ State="FL"; SUBCODE="FLJEFF"; County="Jefferson" }

    @{ State="FL"; SUBCODE="FLLAFA"; County="Lafayette" }

    @{ State="FL"; SUBCODE="FLLAKE"; County="Lake" }

    @{ State="FL"; SUBCODE="FLLEEX"; County="Lee" }

    @{ State="FL"; SUBCODE="FLLEON"; County="Leon" }

    @{ State="FL"; SUBCODE="FLLEVY"; County="Levy" }

    @{ State="FL"; SUBCODE="FLLIBE"; County="Liberty" }

    @{ State="FL"; SUBCODE="FLMADI"; County="Madison" }

    @{ State="FL"; SUBCODE="FLMANA"; County="Manatee" }

    @{ State="FL"; SUBCODE="FLMARI"; County="Marion" }

    @{ State="FL"; SUBCODE="FLMART"; County="Martin" }

    @{ State="FL"; SUBCODE="FLMONR"; County="Monroe" }

    @{ State="FL"; SUBCODE="FLNASS"; County="Nassau" }

    @{ State="FL"; SUBCODE="FLOKAL"; County="Okaloosa" }

    @{ State="FL"; SUBCODE="FLOKEE"; County="Okeechobee" }

    @{ State="FL"; SUBCODE="FLORAN"; County="Orange" }

    @{ State="FL"; SUBCODE="FLOSCE"; County="Osceola" }

    @{ State="FL"; SUBCODE="FLPALM"; County="Palm Beach" }

    @{ State="FL"; SUBCODE="FLPASC"; County="Pasco" }

    @{ State="FL"; SUBCODE="FLPINE"; County="Pinellas" }

    @{ State="FL"; SUBCODE="FLPOLK"; County="Polk" }

    @{ State="FL"; SUBCODE="FLPUTN"; County="Putnam" }

    @{ State="FL"; SUBCODE="FLSTJO"; County="Saint Johns" }

    @{ State="FL"; SUBCODE="FLSTLU"; County="Saint Lucie" }

    @{ State="FL"; SUBCODE="FLSANT"; County="Santa Rosa" }

    @{ State="FL"; SUBCODE="FLSARA"; County="Sarasota" }

    @{ State="FL"; SUBCODE="FLSEMI"; County="Seminole" }

    @{ State="FL"; SUBCODE="FLSUMT"; County="Sumter" }

    @{ State="FL"; SUBCODE="FLSUWA"; County="Suwannee" }

    @{ State="FL"; SUBCODE="FLTAYL"; County="Taylor" }

    @{ State="FL"; SUBCODE="FLVOLU"; County="Volusia" }

    @{ State="FL"; SUBCODE="FLWAKU"; County="Wakulla" }

    @{ State="FL"; SUBCODE="FLWALT"; County="Walton" }

    @{ State="FL"; SUBCODE="FLWASH"; County="Washington" }

 

    # ===== IDAHO =====

    @{ State="ID"; SUBCODE="IDADAX"; County="Ada" }

    @{ State="ID"; SUBCODE="IDCANY"; County="Canyon" }

 

    # ===== ILLINOIS =====

    @{ State="IL"; SUBCODE="ILCHAM"; County="Champaign" }

    @{ State="IL"; SUBCODE="ILDEKA"; County="DeKalb" }

    @{ State="IL"; SUBCODE="DUPG";   County="Dupage" }

    @{ State="IL"; SUBCODE="ILKANE"; County="Kane" }

    @{ State="IL"; SUBCODE="KNDL";   County="Kendall" }

    @{ State="IL"; SUBCODE="ILLAKE"; County="Lake" }

    @{ State="IL"; SUBCODE="MCHN";   County="McHenry" }

    @{ State="IL"; SUBCODE="ILMCLE"; County="McLean" }

    @{ State="IL"; SUBCODE="ILWILL"; County="Will" }

 

    # ===== INDIANA =====

    @{ State="IN"; SUBCODE="INLAKE"; County="Lake" }

    @{ State="IN"; SUBCODE="INMARI"; County="Marion" }

    @{ State="IN"; SUBCODE="INPRTR"; County="Porter" }

 

    # ===== KENTUCKY =====

    @{ State="KY"; SUBCODE="KYBOON"; County="Boone" }

    @{ State="KY"; SUBCODE="KYBULL"; County="Bullitt" }

    @{ State="KY"; SUBCODE="KYCAMP"; County="Campbell" }

    @{ State="KY"; SUBCODE="KYFAYE"; County="Fayette" }

    @{ State="KY"; SUBCODE="KYHEND"; County="Henderson" }

    @{ State="KY"; SUBCODE="KYHOPK"; County="Hopkins" }

    @{ State="KY"; SUBCODE="KYJEFF"; County="Jefferson" }

    @{ State="KY"; SUBCODE="KYJESS"; County="Jessamine" }

    @{ State="KY"; SUBCODE="KYMADI"; County="Madison" }

    @{ State="KY"; SUBCODE="KYNELS"; County="Nelson" }

    @{ State="KY"; SUBCODE="KYOLDH"; County="Oldham" }

    @{ State="KY"; SUBCODE="KYSCOT"; County="Scott" }

    @{ State="KY"; SUBCODE="KYSHEL"; County="Shelby" }

    @{ State="KY"; SUBCODE="KYWARR"; County="Warren" }

    # ===== MARYLAND =====

    @{ State="MD"; SUBCODE="MDALLE"; County="Allegany" }

    @{ State="MD"; SUBCODE="MDANNE"; County="Anne Arundel" }

    @{ State="MD"; SUBCODE="MDBALT"; County="Baltimore" }

    @{ State="MD"; SUBCODE="MDBLTC"; County="Baltimore City" }

    @{ State="MD"; SUBCODE="MDCALV"; County="Calvert" }

    @{ State="MD"; SUBCODE="MDCARO"; County="Caroline" }

    @{ State="MD"; SUBCODE="MDCARR"; County="Carroll" }

    @{ State="MD"; SUBCODE="MDCECI"; County="Cecil" }

    @{ State="MD"; SUBCODE="MDCHAR"; County="Charles" }

    @{ State="MD"; SUBCODE="MDDORC"; County="Dorchester" }

    @{ State="MD"; SUBCODE="MDFRED"; County="Frederick" }

    @{ State="MD"; SUBCODE="MDGARR"; County="Garrett" }

    @{ State="MD"; SUBCODE="MDHARF"; County="Harford" }

    @{ State="MD"; SUBCODE="MDHOWA"; County="Howard" }

    @{ State="MD"; SUBCODE="MDKENT"; County="Kent" }

    @{ State="MD"; SUBCODE="MDMONT"; County="Montgomery" }

    @{ State="MD"; SUBCODE="MDPRIN"; County="Prince Georges" }

    @{ State="MD"; SUBCODE="MDQUEE"; County="Queen Annes" }

    @{ State="MD"; SUBCODE="MDSTMA"; County="Saint Mary" }

    @{ State="MD"; SUBCODE="MDSOME"; County="Somerset" }

    @{ State="MD"; SUBCODE="MDTALB"; County="Talbot" }

    @{ State="MD"; SUBCODE="MDWASH"; County="Washington" }

    @{ State="MD"; SUBCODE="MDWICO"; County="Wicomico" }

    @{ State="MD"; SUBCODE="MDWORC"; County="Worcester" }

 

    # ===== MICHIGAN =====

    @{ State="MI"; SUBCODE="MIALLE"; County="Allegan" }

    @{ State="MI"; SUBCODE="MIBARR"; County="Barry" }

    @{ State="MI"; SUBCODE="MIBERR"; County="Berrien" }

    @{ State="MI"; SUBCODE="MICALH"; County="Calhoun" }

    @{ State="MI"; SUBCODE="MICASS"; County="Cass" }

    @{ State="MI"; SUBCODE="MICLIN"; County="Clinton" }

    @{ State="MI"; SUBCODE="MIEATO"; County="Eaton" }

    @{ State="MI"; SUBCODE="MIGENE"; County="Genesee" }

    @{ State="MI"; SUBCODE="MIHILL"; County="Hillsdale" }

    @{ State="MI"; SUBCODE="MIINGH"; County="Ingham" }

    @{ State="MI"; SUBCODE="MIKALA"; County="Kalamazoo" }

    @{ State="MI"; SUBCODE="MIKENT"; County="Kent" }

    @{ State="MI"; SUBCODE="MILIVI"; County="Livingston" }

    @{ State="MI"; SUBCODE="MIMACO"; County="Macomb" }

    @{ State="MI"; SUBCODE="MIMECO"; County="Mecosta" }

    @{ State="MI"; SUBCODE="MIMONR"; County="Monroe" }

    @{ State="MI"; SUBCODE="MIMUSK"; County="Muskegon" }

    @{ State="MI"; SUBCODE="MIOAKL"; County="Oakland" }

    @{ State="MI"; SUBCODE="MIOCEA"; County="Oceana" }

    @{ State="MI"; SUBCODE="MIOTTA"; County="Ottawa" }

    @{ State="MI"; SUBCODE="MISAGI"; County="Saginaw" }

    @{ State="MI"; SUBCODE="MISTCL"; County="Saint Clair" }

    @{ State="MI"; SUBCODE="MISTJO"; County="Saint Joseph" }

    @{ State="MI"; SUBCODE="MISANI"; County="Sanilac" }

    @{ State="MI"; SUBCODE="MIVANB"; County="Van Buren" }

    @{ State="MI"; SUBCODE="MIWASH"; County="Washtenaw" }

    @{ State="MI"; SUBCODE="MIWAYN"; County="Wayne" }

 

    # ===== MISSOURI =====

    @{ State="MO"; SUBCODE="MOCLAY"; County="Clay" }

    @{ State="MO"; SUBCODE="MOJACK"; County="Jackson" }

    @{ State="MO"; SUBCODE="MOPLAT"; County="Platte" }

 

    # ===== MONTANA =====

    @{ State="MT"; SUBCODE="MTCASC"; County="Cascade" }

    @{ State="MT"; SUBCODE="MTFLAT"; County="Flathead" }

    @{ State="MT"; SUBCODE="MTGALL"; County="Gallatin" }

    @{ State="MT"; SUBCODE="MTLEWI"; County="Lewis and Clark" }

    @{ State="MT"; SUBCODE="MTMADI"; County="Madison" }

    @{ State="MT"; SUBCODE="MTMISS"; County="Missoula" }

    @{ State="MT"; SUBCODE="MTRAVA"; County="Ravalli" }

    @{ State="MT"; SUBCODE="MTYELL"; County="Yellowstone" }

 

    # ===== NORTH CAROLINA =====

    @{ State="NC"; SUBCODE="NCROWA"; County="Rowan" }

 

    # ===== NEW MEXICO =====

    @{ State="NM"; SUBCODE="NMBERN"; County="Bernalillo" }

 

    # ===== NEVADA =====

    @{ State="NV"; SUBCODE="NVCARC"; County="Carson City" }

    @{ State="NV"; SUBCODE="NVCLAR"; County="Clark" }

    @{ State="NV"; SUBCODE="NVDOUG"; County="Douglas" }

    @{ State="NV"; SUBCODE="NVNYEX"; County="Nye" }

    @{ State="NV"; SUBCODE="NVWASH"; County="Washoe" }

 

    # ===== OHIO =====

    @{ State="OH"; SUBCODE="OHCLAR"; County="Clark" }

    @{ State="OH"; SUBCODE="OHCOLU"; County="Columbiana" }

    @{ State="OH"; SUBCODE="OHCUYA"; County="Cuyahoga" }

    @{ State="OH"; SUBCODE="OHDELA"; County="Delaware" }

    @{ State="OH"; SUBCODE="OHFAIR"; County="Fairfield" }

    @{ State="OH"; SUBCODE="OHFRAN"; County="Franklin" }

    @{ State="OH"; SUBCODE="OHHAMI"; County="Hamilton" }

    @{ State="OH"; SUBCODE="OHLAKE"; County="Lake" }

    @{ State="OH"; SUBCODE="OHMEDI"; County="Medina" }

    @{ State="OH"; SUBCODE="OHPORT"; County="Portage" }

    @{ State="OH"; SUBCODE="OHRICH"; County="Richland" }

    @{ State="OH"; SUBCODE="OHROSS"; County="Ross" }

    @{ State="OH"; SUBCODE="OHSTAR"; County="Stark" }

    @{ State="OH"; SUBCODE="OHSUMM"; County="Summit" }

    @{ State="OH"; SUBCODE="OHTUSC"; County="Tuscarawa" }

    @{ State="OH"; SUBCODE="OHWAYN"; County="Wayne" }

 

    # ===== OREGON =====

    @{ State="OR"; SUBCODE="ORBENT"; County="Benton" }

    @{ State="OR"; SUBCODE="ORCLAC"; County="Clackamas" }

    @{ State="OR"; SUBCODE="ORCLAT"; County="Clatsop" }

    @{ State="OR"; SUBCODE="ORCOLU"; County="Columbia" }

    @{ State="OR"; SUBCODE="ORCOOS"; County="Coos" }

    @{ State="OR"; SUBCODE="ORCROO"; County="Crook" }

    @{ State="OR"; SUBCODE="ORDESC"; County="Deschutes" }

    @{ State="OR"; SUBCODE="ORDOUG"; County="Douglas" }

    @{ State="OR"; SUBCODE="ORJACK"; County="Jackson" }

    @{ State="OR"; SUBCODE="ORJEFF"; County="Jefferson" }

    @{ State="OR"; SUBCODE="ORJOSE"; County="Josephine" }

    @{ State="OR"; SUBCODE="ORLANE"; County="Lane" }

    @{ State="OR"; SUBCODE="ORLINC"; County="Lincoln" }

    @{ State="OR"; SUBCODE="ORLINN"; County="Linn" }

    @{ State="OR"; SUBCODE="ORMARI"; County="Marion" }

    @{ State="OR"; SUBCODE="ORMULT"; County="Multnomah" }

    @{ State="OR"; SUBCODE="ORPOLK"; County="Polk" }

    @{ State="OR"; SUBCODE="ORTILL"; County="Tillamook" }

    @{ State="OR"; SUBCODE="ORWASH"; County="Washington" }

    @{ State="OR"; SUBCODE="ORYAMH"; County="Yamhill" }

 

    # ===== PENNSYLVANIA =====

    @{ State="PA"; SUBCODE="PABERK"; County="Berks" }

    @{ State="PA"; SUBCODE="PACENT"; County="Centre" }

    @{ State="PA"; SUBCODE="PAWEST"; County="Westmoreland" }

 

    # ===== SOUTH CAROLINA =====

    @{ State="SC"; SUBCODE="SCAIKE"; County="Aiken" }

    @{ State="SC"; SUBCODE="SCDORC"; County="Dorchester" }

    @{ State="SC"; SUBCODE="SCLANC"; County="Lancaster" }

 

    # ===== TENNESSEE =====

    @{ State="TN"; SUBCODE="TNANDE"; County="Anderson" }

    @{ State="TN"; SUBCODE="TNBEDF"; County="Bedford" }

    @{ State="TN"; SUBCODE="TNBRAD"; County="Bradley" }

    @{ State="TN"; SUBCODE="TNCAMP"; County="Campbell" }

    @{ State="TN"; SUBCODE="TNCART"; County="Carter" }

    @{ State="TN"; SUBCODE="TNCHEA"; County="Cheatham" }

    @{ State="TN"; SUBCODE="TNCCKE"; County="Cocke" }

    @{ State="TN"; SUBCODE="TNCOFF"; County="Coffee" }

    @{ State="TN"; SUBCODE="TNCUMB"; County="Cumberland" }

    @{ State="TN"; SUBCODE="TNDAVI"; County="Davidson" }

    @{ State="TN"; SUBCODE="TNFAYE"; County="Fayette" }

    @{ State="TN"; SUBCODE="TNFRAN"; County="Franklin" }

    @{ State="TN"; SUBCODE="TNGILE"; County="Giles" }

    @{ State="TN"; SUBCODE="TNGREE"; County="Greene" }

    @{ State="TN"; SUBCODE="TNHAMB"; County="Hamblen" }

    @{ State="TN"; SUBCODE="TNHAMI"; County="Hamilton" }

    @{ State="TN"; SUBCODE="TNHAWK"; County="Hawkins" }

    @{ State="TN"; SUBCODE="TNHICK"; County="Hickman" }

    @{ State="TN"; SUBCODE="TNJEFF"; County="Jefferson" }

    @{ State="TN"; SUBCODE="TNLINC"; County="Lincoln" }

    @{ State="TN"; SUBCODE="TNLOUD"; County="Loudon" }

    @{ State="TN"; SUBCODE="TNMACO"; County="Macon" }

    @{ State="TN"; SUBCODE="TNMADI"; County="Madison" }

    @{ State="TN"; SUBCODE="TNMAUR"; County="Maury" }

    @{ State="TN"; SUBCODE="TNMONR"; County="Monroe" }

    @{ State="TN"; SUBCODE="TNRHEA"; County="Rhea" }

    @{ State="TN"; SUBCODE="TNROAN"; County="Roane" }

    @{ State="TN"; SUBCODE="TNROBE"; County="Robertson" }

    @{ State="TN"; SUBCODE="TNRUTH"; County="Rutherford" }

    @{ State="TN"; SUBCODE="TNSEVI"; County="Sevier" }

    @{ State="TN"; SUBCODE="TNSHEL"; County="Shelby" }

    @{ State="TN"; SUBCODE="TNSULL"; County="Sullivan" }

    @{ State="TN"; SUBCODE="TNSUMN"; County="Sumner" }

    @{ State="TN"; SUBCODE="TNUNIO"; County="Union" }

    @{ State="TN"; SUBCODE="TNWASH"; County="Washington" }

    @{ State="TN"; SUBCODE="TNWILL"; County="Williamson" }

    @{ State="TN"; SUBCODE="TNWILS"; County="Wilson" }

 

    # ===== TEXAS =====

    @{ State="TX"; SUBCODE="TXBEXA"; County="Bexar" }

    @{ State="TX"; SUBCODE="TXBRAZ"; County="Brazoria" }

    @{ State="TX"; SUBCODE="TXCOLL"; County="Collin" }

    @{ State="TX"; SUBCODE="TXCOMA"; County="Comal" }

    @{ State="TX"; SUBCODE="TXDLLS"; County="Dallas" }

    @{ State="TX"; SUBCODE="TXDENT"; County="Denton" }

    @{ State="TX"; SUBCODE="TXELPA"; County="El Paso" }

    @{ State="TX"; SUBCODE="TXFORT"; County="Fort Bend" }

    @{ State="TX"; SUBCODE="TXGALV"; County="Galveston" }

    @{ State="TX"; SUBCODE="TXGUAD"; County="Guadalupe" }

    @{ State="TX"; SUBCODE="TXHARR"; County="Harris" }

    @{ State="TX"; SUBCODE="TXHUNT"; County="Hunt" }

    @{ State="TX"; SUBCODE="TXJFFN"; County="Jefferson" }

    @{ State="TX"; SUBCODE="TXKAUF"; County="Kaufman" }

    @{ State="TX"; SUBCODE="TXKEND"; County="Kendall" }

    @{ State="TX"; SUBCODE="TXLIBE"; County="Liberty" }

    @{ State="TX"; SUBCODE="TXMCLE"; County="McLennan" }

    @{ State="TX"; SUBCODE="TXMNTY"; County="Montgomery" }

    @{ State="TX"; SUBCODE="TXNUEC"; County="Nueces" }

    @{ State="TX"; SUBCODE="TXPARK"; County="Parker" }

    @{ State="TX"; SUBCODE="TXROCK"; County="Rockwall" }

    @{ State="TX"; SUBCODE="TXSMIT"; County="Smith" }

    @{ State="TX"; SUBCODE="TXTARR"; County="Tarrant" }

    @{ State="TX"; SUBCODE="TXTRAV"; County="Travis" }

    @{ State="TX"; SUBCODE="TXWALL"; County="Waller" }

    @{ State="TX"; SUBCODE="TXWLSN"; County="Williamson" }

 

    # ===== UTAH =====

    @{ State="UT"; SUBCODE="UTSALT"; County="Salt Lake" }

 

    # ===== WASHINGTON =====

    @{ State="WA"; SUBCODE="WAADAM"; County="Adams" }

    @{ State="WA"; SUBCODE="WABENT"; County="Benton" }

    @{ State="WA"; SUBCODE="WACLAR"; County="Clark" }

    @{ State="WA"; SUBCODE="WACOWL"; County="Cowlitz" }

    @{ State="WA"; SUBCODE="WAFRAN"; County="Franklin" }

    @{ State="WA"; SUBCODE="WAGRAN"; County="Grant" }

    @{ State="WA"; SUBCODE="WAISLA"; County="Island" }

    @{ State="WA"; SUBCODE="WAKING"; County="King" }

    @{ State="WA"; SUBCODE="WAKITS"; County="Kitsap" }

    @{ State="WA"; SUBCODE="WAOKAN"; County="Okanogan" }

    @{ State="WA"; SUBCODE="WAPIER"; County="Pierce" }

    @{ State="WA"; SUBCODE="WASANJ"; County="San Juan" }

    @{ State="WA"; SUBCODE="WASKAG"; County="Skagit" }

    @{ State="WA"; SUBCODE="WASNOH"; County="Snohomish" }

    @{ State="WA"; SUBCODE="WASPOK"; County="Spokane" }

    @{ State="WA"; SUBCODE="WATHUR"; County="Thurston" }

    @{ State="WA"; SUBCODE="WAWHAT"; County="Whatcom" }

    @{ State="WA"; SUBCODE="WAYAKI"; County="Yakima" }

 

    # ===== WISCONSIN =====

    @{ State="WI"; SUBCODE="WIADAM"; County="Adams" }

    @{ State="WI"; SUBCODE="WICOLU"; County="Columbia" }

    @{ State="WI"; SUBCODE="WIDANE"; County="Dane" }

    @{ State="WI"; SUBCODE="WIJUNE"; County="Juneau" }

    @{ State="WI"; SUBCODE="WIMILW"; County="Milwaukee" }

    @{ State="WI"; SUBCODE="WISAUK"; County="Sauk" }

    @{ State="WI"; SUBCODE="WIWALW"; County="Walworth" }

    @{ State="WI"; SUBCODE="WIWAUK"; County="Waukesha" }

)

 

 

# ------------------------------------------------------

# COLLECT DATA

# ------------------------------------------------------

$Data = @{}

 

foreach ($County in $Counties) {

 

    $LatestImage   = ""

    $ProcessedDate = $null

 

    # Derive folder name automatically

    $FolderName = "$($County.State)-$($County.County)"

    $Path = Join-Path (Join-Path $BasePath $FolderName) "Recorded Docs"

 

    if (-not (Test-Path $Path)) {

        Write-Warning "Missing folder: $Path"

        continue

    }

 

    $Log = Get-ChildItem $Path -Filter "*.LOG" -File |

           Sort-Object LastWriteTime -Descending |

           Select-Object -First 1

 

    if ($Log) {

 

        # ---- Latest Image (SUBCODE + last number) ----

        $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($Log.Name)

        $Parts = $BaseName -split "-"

 

        $Index = -1

        for ($i = $Parts.Count - 1; $i -ge 0; $i--) {

            if ($Parts[$i] -eq $County.SUBCODE) {

                $Index = $i

                break

            }

        }

 

        if ($Index -ge 0 -and $Index + 1 -lt $Parts.Count) {

            $LatestImage = "$($Parts[$Index])-$($Parts[$Index + 1])"

        }

        else {

            $LatestImage = $BaseName

        }

 

        # ---- Processed Date ----

        $Line = Get-Content $Log.FullName -TotalCount 1

        if ($Line -match "(\d{4}-[A-Za-z]{3}-\d{2}\s\d{2}:\d{2})") {

            $ProcessedDate = [datetime]::ParseExact(

                $Matches[1],

                "yyyy-MMM-dd HH:mm",

                $null

            )

        }

        else {

            $ProcessedDate = $Log.LastWriteTime

        }

    }

 

    $Data[$County.SUBCODE] = @{

        State=$County.State

        County=$County.County

        SUBCODE=$County.SUBCODE

        LatestImage=$LatestImage

        ProcessedDate=$ProcessedDate

    }

}

 

# ------------------------------------------------------

# EXCEL OUTPUT

# ------------------------------------------------------

$Excel = New-Object -ComObject Excel.Application

$Excel.Visible = $false

 

$IsNew = -not (Test-Path $ExcelPath)

$Workbook = if ($IsNew) { $Excel.Workbooks.Add() } else { $Excel.Workbooks.Open($ExcelPath) }

 

$Sheet = $Workbook.Worksheets.Item(1)

$Sheet.Name = "Processed Dates"

 

if ($IsNew) {

    "State","County","SUBCODE","Latest Image","Processed Date" |

    ForEach-Object -Begin { $c=1 } {

        $Sheet.Cells.Item(1,$c) = $_

        $Sheet.Cells.Item(1,$c).Font.Bold = $true

        $c++

    }

}

 

$row = 2

foreach ($County in $Counties) {

 

    $R = $Data[$County.SUBCODE]

    $OldText = $Sheet.Cells.Item($row,5).Text

    $OldDate = if ($OldText) { [datetime]$OldText } else { $null }

 

    $Sheet.Cells.Item($row,1) = $R.State

    $Sheet.Cells.Item($row,2) = $R.County

    $Sheet.Cells.Item($row,3) = $R.SUBCODE

    $Sheet.Cells.Item($row,4) = $R.LatestImage

 

    if ($R.ProcessedDate) {

        $Sheet.Cells.Item($row,5) = $R.ProcessedDate

    }

 

    if (-not $IsNew -and $OldDate -and $R.ProcessedDate -gt $OldDate) {

        $Sheet.Cells.Item($row,5).Interior.ColorIndex = 4

    }

 

    $row++

}

 

$Sheet.UsedRange.EntireColumn.AutoFit()

 

if ($IsNew) { $Workbook.SaveAs($ExcelPath) } else { $Workbook.Save() }

$Workbook.Close($true)

$Excel.Quit()

[System.Runtime.InteropServices.Marshal]::ReleaseComObject($Excel) | Out-Null

 

Write-Host "Master Processed Dates dashboard updated successfully." -ForegroundColor Green