
#These maps were created using the tutorial by @joelnitta "Obtaining occurrence and phylogeny data in R"
#https://github.com/joelnitta/spatial-phy-workshop/blob/main/tutorials/occ_phy.md
 
#Please see this tutorial for setup and other detailed information

library(rgbif)
library(tidyverse)

#genus_ID for Psora on GBIF is 5953400. You can redo these maps with other taxa by changing the taxon id.
taxon_id <- 5953400

#I initially completed this download 2024-12-02 from GBIF using rgbif
occ_download_prep(pred_in("taxonKey", taxon_id), pred("hasCoordinate", TRUE))

#I am going to redo the download and see what has changed
occ_download(pred_in("taxonKey", taxon_id), pred("hasCoordinate", TRUE))

#This is my new download for 2026-05-30
# <<gbif download>>
# Your download is being processed by GBIF:
#   https://www.gbif.org/occurrence/download/0025991-260519110011954
# Most downloads finish within 15 min.
# Check status with
# occ_download_wait('0025991-260519110011954')
# After it finishes, use
# d <- occ_download_get('0025991-260519110011954') %>%
#   occ_download_import()
# to retrieve your download.
# Download Info:
#   Username: ann.evankow
# E-mail: ann.evankow@gmail.com
# Format: DWCA
# Download key: 0025991-260519110011954
# Created: 2026-05-30T21:09:27.860+00:00
# Citation Info:  
#   Please always cite the download DOI when using this data.
# https://www.gbif.org/citation-guidelines
# DOI: 
#   Citation:
#   GBIF Occurrence Download https://www.gbif.org/occurrence/download/0025991-260519110011954 Accessed from R via rgbif (https://github.com/ropensci/rgbif) on 2026-05-30

#My older download:
#<<gbif download>>
# <<gbif download>>
# Your download is being processed by GBIF:
#   https://www.gbif.org/occurrence/download/0011647-241126133413365
# Most downloads finish within 15 min.
# Check status with
# occ_download_wait('0011647-241126133413365')
# After it finishes, use
# d <- occ_download_get('0011647-241126133413365') %>%
#   occ_download_import()
# to retrieve your download.
# Download Info:
#   Username: ann.evankow
# E-mail: ann.evankow@gmail.com
# Format: DWCA
# Download key: 0011647-241126133413365
# Created: 2024-12-02T12:35:17.189+00:00
# Citation Info:  
#   Please always cite the download DOI when using this data.
# https://www.gbif.org/citation-guidelines
# DOI: 10.15468/dl.6zrq67
# Citation:
#   GBIF Occurrence Download https://doi.org/10.15468/dl.6zrq67 Accessed from R via rgbif (https://github.com/ropensci/rgbif) on 2024-12-02

#import older download
psora_records_world <- occ_download_get('0011647-241126133413365') %>%
  occ_download_import()

#import new download
psora_records_world_2026 <- occ_download_get('0025991-260519110011954') %>%
  occ_download_import()

library(dplyr)
glimpse(psora_records_world[1, ])
#Rows: 1, Columns: 223

psora_records_world %>%
  count(basisOfRecord)

#Results from first download
# A tibble: 8 × 2
# basisOfRecord           n
# <chr>               <int>
#   1 HUMAN_OBSERVATION    6609
# 2 LIVING_SPECIMEN         1
# 3 MACHINE_OBSERVATION     1
# 4 MATERIAL_CITATION      76
# 5 MATERIAL_SAMPLE        98
# 6 OBSERVATION            59
# 7 OCCURRENCE             70
# 8 PRESERVED_SPECIMEN   9528

psora_records_world_2026 %>%
  count(basisOfRecord)

#Results from new download
# A tibble: 8 × 2
# basisOfRecord           n
# <chr>               <int>
#   1 HUMAN_OBSERVATION    8643
# 2 LIVING_SPECIMEN         1
# 3 MACHINE_OBSERVATION     6
# 4 MATERIAL_CITATION      83
# 5 MATERIAL_SAMPLE       681
# 6 OBSERVATION            59
# 7 OCCURRENCE             69
# 8 PRESERVED_SPECIMEN  11122

#The number of Human observations increased by more than 2000 in less than 2 years.
#The number of digitized preserved specimens increased by more than 1500 as well.
#There are also more machine observations and material samples.

psora_records_world %>%
  group_by(basisOfRecord) %>%
  summarize(
    n_sp = n_distinct(species)
  )

# # A tibble: 8 × 2
# basisOfRecord        n_sp
# <chr>               <int>
#   1 HUMAN_OBSERVATION      24
# 2 LIVING_SPECIMEN         1
# 3 MACHINE_OBSERVATION     1
# 4 MATERIAL_CITATION       5
# 5 MATERIAL_SAMPLE         6
# 6 OBSERVATION             4
# 7 OCCURRENCE              6
# 8 PRESERVED_SPECIMEN     33

psora_records_world_2026 %>%
  group_by(basisOfRecord) %>%
  summarize(
    n_sp = n_distinct(species)
  )

# A tibble: 8 × 2
# basisOfRecord        n_sp
# <chr>               <int>
#   1 HUMAN_OBSERVATION      25
# 2 LIVING_SPECIMEN         1
# 3 MACHINE_OBSERVATION     1
# 4 MATERIAL_CITATION       6
# 5 MATERIAL_SAMPLE        26
# 6 OBSERVATION             4
# 7 OCCURRENCE              6
# 8 PRESERVED_SPECIMEN     37

#The number of species from human observations increased by 1. The number of species from preserved specimens increased by 4. 

#How many species are only represented by HUMAN_OBSERVATION records? In other words, if we were to drop all HUMAN_OBSERVATION records, how many species would we lose?
psora_records_world %>%
  group_by(species) %>%
  add_count(basisOfRecord) %>%
  filter(basisOfRecord == "HUMAN_OBSERVATION", n == 1) %>%
  count(species)

# A tibble: 3 × 2
# Groups:   species [3]
# species               n
# <chr>             <int>
#   1 Psora californica     1
# 2 Psora subfumosa       1
# 3 Psora taurensis       1

psora_records_world_2026 %>%
  group_by(species) %>%
  add_count(basisOfRecord) %>%
  filter(basisOfRecord == "HUMAN_OBSERVATION", n == 1) %>%
  count(species)

# A tibble: 3 × 2
# Groups:   species [3]
# species             n
# <chr>           <int>
#   1 Psora pruinosa      1
# 2 Psora subfumosa     1
# 3 Psora taurensis     1

#These results are confusing to me. I will need to follow up with them.

# Download world map data
library(rnaturalearth)

world_map <- ne_countries(returnclass = "sf")

#map of points from 2024
ggplot()+
  geom_sf(data = world_map) +
  geom_point(
    data = psora_records_world,
    aes(x = decimalLongitude, y = decimalLatitude, color = species),
    size = 0.5) +
  theme(legend.position = "none")

#map of points from 2026
ggplot()+
  geom_sf(data = world_map) +
  geom_point(
    data = psora_records_world_2026,
    aes(x = decimalLongitude, y = decimalLatitude, color = species),
    size = 0.5) +
  theme(legend.position = "none")

#I do not see any obvious differences between these two maps, except that there are more points on the newer map.

#Did you notice the warning message when we ran ggplot(). No, but we will clean the data anyway.
psora_records_world_no_missing <-
  psora_records_world %>%
  # Also remove data that are missing species names
  mutate(species = na_if(species, "")) %>%
  filter(
    !is.na(species),
    !is.na(decimalLongitude),
    !is.na(decimalLatitude)
  )

psora_records_world_no_missing
#A tibble: 15,907 × 223

#also clean the data for 2026
psora_records_world_no_missing_2026 <-
  psora_records_world_2026 %>%
  # Also remove data that are missing species names
  mutate(species = na_if(species, "")) %>%
  filter(
    !is.na(species),
    !is.na(decimalLongitude),
    !is.na(decimalLatitude)
  )

psora_records_world_no_missing_2026
# A tibble: 20,073 × 230

library(phyloregion)
library(sf)

#Convert raw input distribution data to community ?points2comm
commW <-
  points2comm(
    dat = select(
      psora_records_world_no_missing, species,
      decimallongitude = decimalLongitude,
      decimallatitude = decimalLatitude),
    res = 2
  )

#Exploring commW 
names(commW)
commW$comm_dat[1:6, 1:6]

#poly_shp is the GIS layer data: the shapes of the grid-cells.
commW$map

#Calculating redundancy is straightforward with the output from points2comm().
redundancy_res_2_w <-
  commW$map %>%
  as_tibble() %>%
  mutate(redundancy = 1 - richness/abundance)

#We could then plot a histogram or bar chart to take a closer look:
ggplot(redundancy_res_2_w, aes(x = redundancy)) +
  geom_histogram()

#Convert raw 2026 input distribution data to community ?points2comm
comm2026 <-
  points2comm(
    dat = select(
      psora_records_world_no_missing_2026, species,
      decimallongitude = decimalLongitude,
      decimallatitude = decimalLatitude),
    res = 2
  )

#Calculating redundancy for 2026.
redundancy_res_2_2026 <-
  comm2026$map %>%
  as_tibble() %>%
  mutate(redundancy = 1 - richness/abundance)

#We then polot the histogram for 2026.
ggplot(redundancy_res_2_2026, aes(x = redundancy)) +
  geom_histogram()

# Set the CRS to match between the background map and points
poly_shp_sf_w <- st_as_sf(commW$map)
st_crs(poly_shp_sf_w) <- st_crs(world_map)

#plot data from 2024 using the viridis color scale (as shown in the tutorial).
ggplot() +
  geom_sf(data = world_map) +
  geom_sf(
    data = poly_shp_sf_w,
    aes(fill = richness)
  ) +
  # Use a log scale because richness is highly skewed
  scale_fill_viridis_c(trans = "log10")

plain <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank(),
  panel.background = element_rect(fill = "gray90"),
  plot.title = element_text(hjust = 0.5)
)

#plot data from 2024 using a scale of yellow to red
ggplot() +
  geom_sf(data = world_map, colour = "black", fill = "white") +
  geom_sf(
    data = poly_shp_sf_w,
    aes(fill = richness)
  ) + plain +
  scale_fill_gradient(low = "yellow", high = "red") 
# Use a log scale because richness is highly skewed
#scale_fill_viridis_c() +
# scale_fill_viridis_c(trans = "log10") +
#coord_sf(crs="+proj=moll +datum=WGS84 +units=m")

# Set the CRS to match between the background map and points from 2026
poly_shp_sf_2026 <- st_as_sf(comm2026$map)
st_crs(poly_shp_sf_2026) <- st_crs(world_map)

#plot data from 2026 using the viridis color scale
ggplot() +
  geom_sf(data = world_map) +
  geom_sf(
    data = poly_shp_sf_2026,
    aes(fill = richness)
  ) +
  # Use a log scale because richness is highly skewed
  scale_fill_viridis_c(trans = "log10")

#plot data from 2026 using a scale of yellow to red
ggplot() +
  geom_sf(data = world_map, colour = "black", fill = "white") +
  geom_sf(
    data = poly_shp_sf_2026,
    aes(fill = richness)
  ) + plain +
  scale_fill_gradient(low = "yellow", high = "red") 
# Use a log scale because richness is highly skewed
#scale_fill_viridis_c() +
# scale_fill_viridis_c(trans = "log10") +
#coord_sf(crs="+proj=moll +datum=WGS84 +units=m")



