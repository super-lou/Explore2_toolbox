# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# # Read multiple SVG somehow
# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# path="/home/louis/Documents/bouleau/INRAE/project/Ex2D_project/Ex2D_toolbox/resources/icon/"
# statue   <- paste(readLines(file.path(path, "Baseflow.svg")),
#                   collapse = "\n")
# building <- paste(readLines(file.path(path, "Bias.svg")),
#                   collapse = "\n")
# sign     <- paste(readLines(file.path(path, "Climat.svg")),
#                   collapse = "\n")


# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# # Define a data.frame mapping 'type' to actual 'svg'
# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# icons_df <- data.frame(
#   type = c('statue', 'building', 'sign'),
#   svg  = c( statue ,  building ,  sign ),
#   stringsAsFactors = FALSE
# )

# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# # Create some Points-of-Interest and assign an svg to each
# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# N <- 20
# poi <- data.frame(
#   lat = runif(N),
#   lon = runif(N),
#   type = sample(c('statue', 'building', 'sign'), N, replace = TRUE),
#   stringsAsFactors = FALSE
# )

# poi <- merge(poi, icons_df)


# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# # {ggsvg}
# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# plot=ggplot(poi) + 
#   geom_point_svg(
#     aes(x = lon, y = lat, svg = I(svg)),
#     size = 10
#   ) + 
#   labs(
#     title = "{ggsvg} multiple SVG images"
#   ) + 
#   theme_bw()

# ggsave("test.svg", plot)


# ggplot(poi) + 
#   geom_point_svg(
#     aes(x = lon, y = lat, svg = type),
#     size = 10
#   ) + 
#   scale_svg_discrete_manual(
#     aesthetics = 'svg', 
#     values = c(statue = statue, building = building, sign = sign),
#     guide = guide_legend(override.aes = list(size = 5))
#   ) + 
#   labs(
#     title = "{ggsvg} multiple SVG images"
#   ) + 
#   theme_bw()




     # ggplot() +
     #   annotate(
     #     ggpath::GeomFromPath,
     #     x = 0,
     #     y = 0,
     #     path = local_image_path,
     #     width = 0.4
     #   ) +
     #   theme_minimal()

# local_image_path <- system.file("r_logo.png", package = "ggpath")

# library(ggplot2)
# library(ggpath)
# plot_data <- data.frame(x = c(-1, 1), y = 1, path = local_image_path)
# plot = ggplot(plot_data, aes(x = x, y = y)) +
#   geom_from_path(aes(path = path), width = 0.2) +
#   coord_cartesian(xlim = c(-2, 2)) +
#   theme_minimal()

# ggsave("test.pdf", plot)


#  remotes::install_github('coolbutuseless/hershey')
# library(hershey)
# library(ggsvg)

# svg_text <- '
#   <svg viewBox="0 0 100 100 ">
#     <polygon points = "20,80 80,80 50,20" fill="darkgreen" />
#     <polygon points = "40,83 60,83 60,95 40,95" fill="darkred" />
#     <polygon points = "58.66 25.00 50.00 30.00 41.34 25.00 41.34 15.00 50.00 10.00 58.66 15.00 58.66 25.00" 
#        fill="yellow3" />
#   </svg>
#   '

# letter <- hershey[hershey$char == 'R' & hershey$font == 'scriptc',]

# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# # Use 'geom_point_svg' to plot SVG image at each point
# #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# plot = ggplot(letter) +
#   geom_path(aes(x, y, group = stroke), alpha = 0.5) +
#   geom_point_svg(
#     mapping  = aes(x, y),
#     svg      = svg_text,
#     size     = 10
#   ) +
#   theme_bw() + 
#   coord_equal() + 
#   labs(
#     title    = "Merry Christmas #RStats",
#     subtitle = "{ggsvg} Using SVG as points"
#   )
# ggsave("test.pdf", plot)

# grob <- svgparser::read_svg(svg_text)
# # grid::grid.newpage()
# # grid::grid.draw(grob)


# library(grid)
library(ggplot2)
# library(svgparser)

rlogo_url <- 'https://www.r-project.org/logo/Rlogo.svg'
rlogo     <- svgparser::read_svg(rlogo_url)

plot = ggplot(mtcars) + 
  geom_point(aes(mpg, wt)) +
  annotation_custom(rlogo, xmin = 28, xmax = 33, ymin = 4, ymax = 5) +
  labs(title = "svgparser::read_svg() + ggplot2") + 
  theme_bw()
ggsave("test.pdf", plot)
