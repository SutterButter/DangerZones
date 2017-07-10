

# Danger Zones
## Overview
Every year, hundreds of thousands of people are injured when
they fail to see, or see without actually seeing, while driving. If these
people were simply paying better attention to the road and task at hand, they
could prevent their accident alltogether. For State Farm's Hackday 2017, I
wanted to devise a way to help prevent people from being involved in this type
of accident. To do this my hack needed to be easily accessible to most people,
be hassle free, and somehow prevent lack of seeing accidents. After some though
I settled on designing an iOS navigation app that would balance driving routes
between safety and speed and warn users of upcoming dangerous portions of road
so that they could be more alert when in a potentially dangerous situation. 
## The Data
In order to make a navigation app that warns of dangerous
portions of road, I first had to identify the dangerous road sections. And to
do that, I needed to figure out where people consistently crash. I decided to
focus this prototype on Ohio as I would already know the dangerous
intersections and roads because I grew up there. Specifically I focused on
Stark County Ohio. 

As it turns out, the Ohio Department of Public Safety puts
out car crash data on a daily basis. Their website allows you to select the
time frame and for what parts of Ohio you want the crash data. The data goes
back years and it is all available for download. The download comes as a file
containing 4 text file and a readme. Each of these 4 text files contains
different data, but it is all stored the same way. The data has no delimiters,
but there is a guide on the website that tells what data is at what indexes.
The website is mostly accurate with only a few minor discrepancies. 

The first text file contains general crash data including
the GPS location of the crash, the date of the crash, what the road conditions
were like, how severe the crash was, and even an exact recounting of the crash
(Encoded). 
The second text file contains Ohio department of transportation
crash data which is just a very brief simplified version of the crash data. 
The third text file contains non-identifiable data on the
people involved in the car crash. 
The fourth text file contains data on the units involved in
the crash such as the make and model of the car.

I settled on using the general crash data to create the map
of dangerous portions of road because it contained GPS data and I could use the
crash severity to determine how dangerous every area was. I took this data and
ran it through a python program that ran through the crash data and pulled out
each of the fields into variables. The next step was to take the crash
locations and start to figure out where there seemed to be heavy amounts of
crashes in a small area. The obvious solution to doing this was to use a
clustering algorithm. I settled on using SciKitLearn's Density-Based Spatial Clustering of Applications with Noise (DBSCAN) algorithm because the data determines the clusters as opposed to something like a k-means
clustering algorithm where you have to specify the number of clusters. This
DBSCAN algorithm took in a maximum distance between points and the minimum
number of points to be considered a cluster, I used 40 meters and 10 points
minimum per cluster. Once it figured out where the clustered points were, the
python program went through and averaged the locations of the crashes for each
cluster to get a sort of center point. While doing this the program also
extracted the crash severities and compiled them to make an overall Danger
Score for each of the clusters. This Danger Score is a function of the crash
severities (only property damage, injuries, or fatal) and the amount of crashes
per cluster. Once this was done I took this data and imported it into Xcode so
that I could run potential routes against it. If given time in the future I
plan to put the data into firebase so that it could scale to cover the whole
United States. I would then query it so that I only get back certain clusters
to check against, reducing run time.
## The Routes
Due to legal constraints I was forced to use Apple's MapKit
in order to do the actual routing between locations that a navigation app is
required to do. MapKit allows you to request a route based on a start point and
a destination. This request can even specify that you want to find alternative
routes as well. For DangerZones, I built a MapKit search bar into the main page
that displays the map and the user’s current location so that they could find
destinations easily. This search bar automatically populates destination
location options as the user types. Once a user chooses a location, a pin is
dropped on the map that allows users to check if they selected the correct
destination. Users can then click the pin and click the car icon from the pin callout
that appears to start navigating. 

Clicking the car icon triggers an event that requests a route and alternatives from the
current location to the destination. The app the takes each of the potential
routes and checks if any Danger Zones fall along them. Now, because I had to
use Apple’s MapKit for this project, I did not have access to handy methods
such as isLocationOnEdge() which checks if a specific point is on the route and
is a part of the Google Maps SDK. I had to write my own algorithm to check if a
point lies along the path. The way the app does this is by first breaking down
the route.

MapKit stores the physical part of a route as MKPolylines which are made up of
endpoints between small line segments that make the shape of the route. Straight
portions of road have few endpoints while curves have many for example. In
order to check if the route intersects any Danger Zones the app breaks down the
route Polyline into smaller Polylines, going point by point, starting with the
first two, until the entire path is traversed. Each of these small straight
Polylines is then checked against one Danger Zone at a time to see if the two
overlap. MapKit can check if two shapes intersect on screen. It can also test
if two shapes would intersect if they were to be placed on the screen. So to
check if a Danger Zone intersects the route, I make a square 100 meters by 100
meters (or the onscreen equivalent using a conversion factor, this changes
based on how zoomed in the user is on the map). The app then checks if that
square will intersect with the Polyline using the built in intersects()
function. If they intersect, the Danger Zone falls on the route. 

Once the app knows what Danger Zones fall on the route, it can calculate how dangerous
each of the routes is by adding up the Danger Scores (which was found earlier
using the python program) of each of the zones that are on the route. The app
then selects the safest of the potential routes (main and alternative routes)
to be the route that the car should follow. This provides a balance between
safety and speed. MapKit only provides alternative routes when they are roughly
equivalent in travel time and distance. Therefore there is a negligible difference
in time it takes to traverse each of the routes yet the chosen route may be much
safer than the alternatives.
## Turn by Turn Directions and Notifying the User of DangerZones
Once the user starts navigation, the search bar becomes a
blank bar where directions can be displayed. MapKit also breaks directions down
for each route by steps that come with text descriptions of how the driver
should proceed. The app contains basic code that checks when the user nears the
end of a step (within 50 meters) to announce that the user should execute the
next step. The announcement should be something like “Turn right onto Main St
NW.” Once that step is announced the app waits until the user is at least 50
meters away from having finished the last step and announces what the next step
will be and the distance to the step. This will be something like “In 1.4
miles, turn left onto 5th street.”  Each of these instructions are announced out
loud using Apple’s built in speech synthesizer and displayed as text at the top
of the screen. Meanwhile, Danger Zones are announced audibly when the user gets
within 500 feet of any danger zone. Although Danger Zones that happen to lie in
close proximity to the one last announce are not announced as it would be
distracting to the driver to continually hear that they are nearing a Danger
Zone. While giving these directions, the app also follows the user by keeping
the user’s current location at the center of the screen.  
## Future Work
There is room for some potential future work. One area that
needs to be reworked is how the Danger Zones are stored. They are currently
hard coded into the app as it was a 24 hour hackathon project and I did not
have the time to actually build a scalable database. Given more time, I would
have put the Danger Zones into a firebase database (or something similar). I
also would have used queries to limit which Danger Zones came back depending on
the route I was requesting instead of checking the route against every Danger
Zone that is stored. I also would have changed the way that the map follows the
user. Currently the map follows the user from an overhead view always facing
north. If given more time I would reorient the map to face the same direction
as the user was traveling along the route. I also would have switched from
directly overhead to a more angled third person view. Furthermore, given the
time, I would have implemented the ability for users to see all the danger
zones in their area. Finally, I also would have allowed the user to override
the app’s decision to pick the safest route, showing multiple route options and
allowing the user to pick from them. 
## Final Thoughts
Overall I think that Danger Zones solves the problem that it
initially set out to solve. It provides turn by turn directions along a safe
route, and it announces dangerous portions of road, as it comes across them. It
offers a simple, easy to understand UI that allows users to quickly navigate
the app. The app is also able to quickly find and process a route that is both
safe and quick. Lastly, the app actually works for any directions in Stark
County Ohio, and it is set to be scaled to cover the entire country given a few
minor tweaks. 



