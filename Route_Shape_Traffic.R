library(googleway)
library(purrr)
library(ggmap)

# Model inputs****************************************************************************************************
# Set your Google Maps API key
api_key     <- "Your Google Maps API Key" # Replace it with your google maps api key
register_google(key = api_key)
# Example locations
origin      <- "New York, NY" # Replace with the origin address 
destination <- "Washington, DC" # Replace with the destination address.
mode        <- "driving"
departure_time <-  "now" # Use "now" to consider current traffic conditions
traffic_model  <- "best guess" #one of 'best_guess', 'pessimistic' or 'optimistic'
# ***************************************************************************************************************

# Get the driving route from Google Maps Directions API, considering traffic conditions
route_data <- google_directions(
  origin = origin,
  destination = destination,
  key = api_key,
  mode = mode, # one of "driving", "walking", "bicycling", "transit"
  departure_time = departure_time, # Use "now" to consider current traffic conditions
  traffic_model  = traffic_model, #one of 'best_guess', 'pessimistic' or 'optimistic'
  units = c("imperial")
)
# extracting the estimated distance and travel time betwen origin and destination:
Distance <- route_data$routes$legs[[1]][["distance"]][["text"]]
Duration <- route_data$routes$legs[[1]][["duration_in_traffic"]]

# Extract the route coordinates
route_coords <- route_data$routes$legs[[1]]$steps %>% 
  purrr::map("start_location") %>% 
  purrr::map_df(~as.data.frame(.))

# Create the bounding box for the route
route_bbox <- make_bbox(route_coords$lng, route_coords$lat, f = 0.1)

# Get the map with the route's bounding box
map_data <- get_map(location = route_bbox, source = "google", maptype = "roadmap")

# Plot the map and the route
ggmap(map_data) +
  geom_path(
    aes(x = lng, y = lat),
    data = route_coords,
    color = "blue",
    size = 1.5,
    lineend = "round"
  ) +
  geom_point(aes(x = lng, y = lat), data = route_coords[1,], color = "green", size = 4) +
  geom_point(aes(x = lng, y = lat), data = route_coords[nrow(route_coords),], color = "red", size = 4) +
  ggtitle(paste("Driving Duration based on the",traffic_model, "traffic modal is", route_data$routes$legs[[1]][[1,2]]))+
  labs(subtitle = paste("The distance between", origin,"and", destination, "is", route_data$routes$legs[[1]][[1,1]]))


