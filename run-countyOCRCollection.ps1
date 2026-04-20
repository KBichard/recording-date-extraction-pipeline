# ============================================================

# Run-CountyOCRCollection.ps1

# PURPOSE:

# - Discover latest county ZIPs

# - Extract recent document images

# - OCR each image

# - SAVE OCR TEXT FILES

# ============================================================

 

$ErrorActionPreference = "Stop"

 

# ---------------- CONFIG ----------------

 

$BasePath     = \\flmaipiqnas01\Imaging5\QC Requests\Kurtis\Dashboard

$OutRoot      = "$BasePath\Output"

 

$TxtOutDir    = "$OutRoot\txt"

$PdfOutDir    = "$OutRoot\pdf"

$WorkDir      = "$OutRoot\work"

 

$CountiesRoot = \\piftp1.pi.local\ftp$\Counties

$Python       = "python"

$OcrScript    = "$BasePath\header_ocr.py"

$MaxDocsPerCounty = 3

 

# ---------------- ENSURE DIRS ----------------

 

New-Item -ItemType Directory -Force -Path $TxtOutDir | Out-Null

New-Item -ItemType Directory -Force -Path $PdfOutDir | Out-Null

New-Item -ItemType Directory -Force -Path $WorkDir   | Out-Null

 

Add-Type -AssemblyName System.IO.Compression.FileSystem

 

# ---------------- COUNTY LIST (MASTER) ----------------

 

$CountyFolders = @(

    # Alabama

    "AL-Baldwin",

    "AL-Madison",

    "AL-Mobile",

    "AL-Shelby",

 

    # Arkansas

    "AR-Benton",

    "AR-Greene",

    "AR-White",

 

    # Arizona

    "AZ-Apache",

    "AZ-Coconino",

    "AZ-Gila",

    "AZ-Graham",

    "AZ-Greenlee",

    "AZ-La Paz",

    "AZ-Maricopa",

    "AZ-Mohave",

    "AZ-Navajo",

    "AZ-Pima",

    "AZ-Pinal",

    "AZ-Yavapai",

    "AZ-Yuma",

 

    # California

    "CA-Alameda",

    "CA-Butte",

    "CA-Colusa",

    "CA-Contra Costa",

    "CA-El Dorado",

    "CA-Fresno",

    "CA-Glenn",

    "CA-Humboldt",

    "CA-Imperial",

    "CA-Inyo",

    "CA-Kern",

    "CA-Kings",

    "CA-Lake",

    "CA-Lassen",

    "CA-Los Angeles",

    "CA-Madera",

    "CA-Marin",

    "CA-Mendocino",

    "CA-Merced",

    "CA-Monterey",

    "CA-Napa",

    "CA-Nevada",

    "CA-Orange",

    "CA-Placer",

    "CA-Plumas",

    "CA-Riverside",

    "CA-Sacramento",

    "CA-San Benito",

    "CA-San Bernardino",

    "CA-San Diego",

    "CA-San Francisco",

    "CA-San Joaquin",

    "CA-San Luis Obispo",

    "CA-San Mateo",

    "CA-Santa Barbara",

    "CA-Santa Clara",

    "CA-Santa Cruz",

    "CA-Shasta",

    "CA-Solano",

    "CA-Sonoma",

    "CA-Stanislaus",

    "CA-Sutter",

    "CA-Tehama",

    "CA-Tulare",

    "CA-Tuolumne",

    "CA-Ventura",

    "CA-Yolo",

    "CA-Yuba",

 

    # Colorado

    "CO-Adams",

    "CO-Arapahoe",

    "CO-Boulder",

    "CO-Broomfield",

    "CO-Clear Creek",

    "CO-Custer",

    "CO-Delta",

    "CO-Denver",

    "CO-Douglas",

    "CO-Eagle",

    "CO-El Paso",

    "CO-Elbert",

    "CO-Fremont",

    "CO-Garfield",

    "CO-Gunnison",

    "CO-Jackson",

    "CO-Jefferson",

    "CO-Larimer",

    "CO-Mesa",

    "CO-Montrose",

    "CO-Ouray",

    "CO-Park",

    "CO-Pueblo",

    "CO-Routt",

    "CO-San Miguel",

    "CO-Summit",

    "CO-Teller",

    "CO-Weld",

 

    # Florida

    "FL-Alachua",

    "FL-Baker",

    "FL-Bay",

    "FL-Bradford",

    "FL-Brevard",

    "FL-Broward",

    "FL-Calhoun",

    "FL-Charlotte",

    "FL-Citrus",

    "FL-Clay",

    "FL-Collier",

    "FL-Columbia",

    "FL-Dade",

    "FL-DeSoto",

    "FL-Dixie",

    "FL-Duval",

    "FL-Escambia",

    "FL-Flagler",

    "FL-Franklin",

    "FL-Gadsden",

    "FL-Gilchrist",

    "FL-Glades",

    "FL-Gulf",

    "FL-Hamilton",

    "FL-Hardee",

    "FL-Hendry",

    "FL-Hernando",

    "FL-Highlands",

    "FL-Hillsborough",

    "FL-Holmes",

    "FL-Indian River",

    "FL-Jackson",

    "FL-Jefferson",

    "FL-Lafayette",

    "FL-Lake",

    "FL-Lee",

    "FL-Leon",

    "FL-Levy",

    "FL-Liberty",

    "FL-Madison",

    "FL-Manatee",

    "FL-Marion",

    "FL-Martin",

    "FL-Monroe",

    "FL-Nassau",

    "FL-Okaloosa",

    "FL-Okeechobee",

    "FL-Orange",

    "FL-Osceola",

    "FL-Palm Beach",

    "FL-Pasco",

    "FL-Pinellas",

    "FL-Polk",

    "FL-Putnam",

    "FL-Saint Johns",

    "FL-Saint Lucie",

    "FL-Santa Rosa",

    "FL-Sarasota",

    "FL-Seminole",

    "FL-Sumter",

    "FL-Suwannee",

    "FL-Taylor",

    "FL-Union",

    "FL-Volusia",

    "FL-Wakulla",

    "FL-Walton",

    "FL-Washington",

 

    # Idaho

    "ID-Ada",

    "ID-Canyon",

 

    # Illinois

    "IL-Champaign",

    "IL-Cook",

    "IL-DeKalb",

    "IL-Dupage",

    "IL-Kane",

    "IL-Kendall",

    "IL-Lake",

    "IL-McHenry",

    "IL-McLean",

    "IL-Will",

 

    # Indiana

    "IN-Allen",

    "IN-La Porte",

    "IN-Lake",

    "IN-Marion",

    "IN-Porter",

    "IN-Whitley",

 

    # Kentucky

    "KY-Boone",

    "KY-Bullitt",

    "KY-Campbell",

    "KY-Fayette",

    "KY-Henderson",

    "KY-Hopkins",

    "KY-Jefferson",

    "KY-Jessamine",

    "KY-Madison",

    "KY-Nelson",

    "KY-Oldham",

    "KY-Scott",

    "KY-Shelby",

    "KY-Warren",

 

    # Maryland

    "MD-Allegany",

    "MD-Anne Arundel",

    "MD-Baltimore",

    "MD-Baltimore City",

    "MD-Calvert",

    "MD-Caroline",

    "MD-Carroll",

    "MD-Cecil",

    "MD-Charles",

    "MD-Dorchester",

    "MD-Frederick",

    "MD-Garrett",

    "MD-Harford",

    "MD-Howard",

    "MD-Kent",

    "MD-Montgomery",

    "MD-Prince Georges",

    "MD-Queen Annes",

    "MD-Saint Mary",

    "MD-Somerset",

    "MD-Talbot",

    "MD-Washington",

    "MD-Wicomico",

    "MD-Worcester",

 

    # Michigan

    "MI-Allegan",

    "MI-Barry",

    "MI-Bay",

    "MI-Berrien",

    "MI-Calhoun",

    "MI-Cass",

    "MI-Clinton",

    "MI-Eaton",

    "MI-Genesee",

    "MI-Hillsdale",

    "MI-Ingham",

    "MI-Kalamazoo",

    "MI-Kent",

    "MI-Lapeer",

    "MI-Livingston",

    "MI-Macomb",

    "MI-Mecosta",

    "MI-Midland",

    "MI-Monroe",

    "MI-Muskegon",

    "MI-Oakland",

    "MI-Oceana",

    "MI-Ottawa",

    "MI-Saginaw",

    "MI-Saint Clair",

    "MI-Saint Joseph",

    "MI-Sanilac",

    "MI-Shiawassee",

    "MI-Van Buren",

    "MI-Washtenaw",

    "MI-Wayne",

 

    # Missouri

    "MO-Clay",

    "MO-Jackson",

    "MO-Platte",

 

    # Montana

    "MT-Cascade",

    "MT-Flathead",

    "MT-Gallatin",

    "MT-Lewis and Clark",

    "MT-Madison",

    "MT-Missoula",

    "MT-Ravalli",

    "MT-Yellowstone",

 

    # North Carolina

    "NC-Rowan",

 

    # New Mexico

    "NM-Bernalillo",

 

    # Nevada

    "NV-Carson City",

    "NV-Clark",

    "NV-Douglas",

    "NV-Nye",

    "NV-Washoe",

 

    # Ohio

    "OH-Clark",

    "OH-Columbiana",

    "OH-Cuyahoga",

    "OH-Delaware",

    "OH-Fairfield",

    "OH-Franklin",

    "OH-Hamilton",

    "OH-Lake",

    "OH-Medina",

    "OH-Portage",

    "OH-Richland",

    "OH-Ross",

    "OH-Stark",

    "OH-Summit",

    "OH-Tuscarawa",

    "OH-Wayne",

 

    # Oregon

    "OR-Benton",

    "OR-Clackamas",

    "OR-Clatsop",

    "OR-Columbia",

    "OR-Coos",

    "OR-Crook",

    "OR-Deschutes",

    "OR-Douglas",

    "OR-Jackson",

    "OR-Jefferson",

    "OR-Josephine",

    "OR-Lane",

    "OR-Lincoln",

    "OR-Linn",

    "OR-Marion",

    "OR-Multnomah",

    "OR-Polk",

    "OR-Tillamook",

    "OR-Washington",

    "OR-Yamhill",

 

    # Pennsylvania

    "PA-Berks",

    "PA-Centre",

    "PA-Westmoreland",

 

    # South Carolina

    "SC-Aiken",

    "SC-Dorchester",

    "SC-Lancaster",

 

    # Tennessee

    "TN-Anderson",

    "TN-Bedford",

    "TN-Bradley",

    "TN-Campbell",

    "TN-Carter",

    "TN-Cheatham",

    "TN-Cocke",

    "TN-Coffee",

    "TN-Cumberland",

    "TN-Davidson",

    "TN-Fayette",

    "TN-Franklin",

    "TN-Giles",

    "TN-Greene",

    "TN-Hamblen",

    "TN-Hamilton",

    "TN-Hawkins",

    "TN-Hickman",

    "TN-Jefferson",

    "TN-Lincoln",

    "TN-Loudon",

    "TN-Macon",

    "TN-Madison",

    "TN-Maury",

    "TN-Monroe",

    "TN-Rhea",

    "TN-Roane",

    "TN-Robertson",

    "TN-Rutherford",

    "TN-Sevier",

    "TN-Shelby",

    "TN-Sullivan",

    "TN-Sumner",

    "TN-Union",

    "TN-Washington",

    "TN-Williamson",

    "TN-Wilson",

 

    # Texas

    "TX-Bexar",

    "TX-Brazoria",

    "TX-Collin",

    "TX-Comal",

    "TX-Dallas",

    "TX-Denton",

    "TX-El Paso",

    "TX-Fort Bend",

    "TX-Galveston",

    "TX-Guadalupe",

    "TX-Harris",

    "TX-Hunt",

    "TX-Jefferson",

    "TX-Kaufman",

    "TX-Kendall",

    "TX-Liberty",

    "TX-McLennan",

    "TX-Montgomery",

    "TX-Nueces",

    "TX-Parker",

    "TX-Rockwall",

    "TX-Smith",

    "TX-Tarrant",

    "TX-Travis",

    "TX-Waller",

    "TX-Williamson",

 

    # Utah

    "UT-Salt Lake",

 

    # Virginia

    "VA-Surry",

 

    # Washington

    "WA-Adams",

    "WA-Benton",

    "WA-Clark",

    "WA-Cowlitz",

    "WA-Franklin",

    "WA-Grant",

    "WA-Island",

    "WA-King",

    "WA-Kitsap",

    "WA-Okanogan",

    "WA-Pierce",

    "WA-San Juan",

    "WA-Skagit",

    "WA-Snohomish",

    "WA-Spokane",

    "WA-Thurston",

    "WA-Whatcom",

    "WA-Yakima",

 

    # Wisconsin

    "WI-Adams",

    "WI-Buffalo",

    "WI-Columbia",

    "WI-Dane",

    "WI-Fond du Lac",

    "WI-Juneau",

    "WI-Milwaukee",

    "WI-Sauk",

    "WI-Walworth",

    "WI-Waukesha"

)

 

 

Write-Host "`n==== OCR COLLECTION START ===="

 

# ---------------- ZIP DISCOVERY ----------------

 

function Get-LatestZip {

    param ($RecordedDocsPath)

 

    if (-not (Test-Path $RecordedDocsPath)) { return $null }

 

    Get-ChildItem $RecordedDocsPath -Filter *.zip |

        Sort-Object LastWriteTime -Descending |

        Select-Object -First 1

}

 

# ---------------- MAIN LOOP ----------------

 

foreach ($county in $CountyFolders) {

 

    Write-Host "`nCounty: $county"

 

    $docPath = Join-Path $CountiesRoot "$county\Recorded Docs"

    $zipFile = Get-LatestZip $docPath

 

    if (-not $zipFile) {

        Write-Host "  No ZIP found"

        continue

    }

 

    Write-Host "  ZIP: $($zipFile.Name)"

 

    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipFile.FullName)

 

    $entries = $zip.Entries |

        Where-Object { $_.Name -match '\.(pdf|tif|tiff)$' } |

        Sort-Object Name -Descending |

        Select-Object -First $MaxDocsPerCounty

 

    foreach ($entry in $entries) {

 

        $docId   = [System.IO.Path]::GetFileNameWithoutExtension($entry.Name)

        $imgPath = Join-Path $WorkDir $entry.Name

        $txtPath = Join-Path $TxtOutDir "$docId.txt"

 

        Write-Host "  OCR: $($entry.Name)"

 

        [System.IO.Compression.ZipFileExtensions]::ExtractToFile(

            $entry, $imgPath, $true

        )

 

        # Archive PDF / image for QA

        $archivedPath = Join-Path $PdfOutDir $entry.Name

        Copy-Item $imgPath $archivedPath -Force

 

        # OCR

        $ocrText = & $Python $OcrScript $imgPath

        $ocrText | Out-File -FilePath $txtPath -Encoding UTF8

 

        Remove-Item $imgPath -Force

    }

 

    $zip.Dispose()

}

 

Write-Host "`n==== OCR COLLECTION COMPLETE ===="