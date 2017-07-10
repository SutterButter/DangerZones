import csv
from sklearn.metrics.pairwise import pairwise_distances
from sklearn.cluster import DBSCAN
from geopy.distance import vincenty
from sklearn import metrics
import numpy as np
from sklearn.preprocessing import StandardScaler

def distance_in_meters(x, y):
    return vincenty((x[0], x[1]), (y[0], y[1])).m

with open('crash.csv', 'wb') as csvFile:
	with open('crashLocations.csv', 'wb') as csvLocationsFile:
		csvWriter = csv.writer(csvFile)
		csvLocationsWriter = csv.writer(csvLocationsFile)
		clusterLocs = []
		with open("Crash.txt") as file:
			for line in file:
				# 'C' to denote a crash
				recordType = line[0:1]

				# Document Number: Unique number assigned by Ohio Department of Public Safety.
				docNumber = line[1:12]

				# Local Report Number: The unique identifier within a given year that identifies a given crash within a state.
				locReport = line[12:26]

				# Crash Severity: 
				# 1 = Fatal Injury
				# 2 = Injury
				# 3 = Property Damage Only (PDO)
				crashSeverity = line[26:27]

				# Private Property Indicator:
				# 1 - occured on private property
				# 2 - did not occur on private property
				ppi = line[27:28]

				# Hit/Run: 
				# 1 = Solved
				# 2 = Unsolved
				hitAndRun = line[28:29]

				# Photos Taken:
				# Were any photos taken relative to the crash? 
				# 1 = Yes
				# 2 = No
				photos = line[29:30]

				# Reporting Agency NCIC: The N.C.I.C agency identifier for the reporting agency. See NCIC Lookup Table (NCIC)
				reportingAgencyNCIC = line[30:35]

				# Number of Units Involved: Total of actual number of motor vehicles and non-motorist involved in crash. Example (01, 02. 03, etc.)
				numUnits= line[35:37]

				# Indicate by unit number the motorist/non-motorist which had the most causative bearing on the crash.
				# 98 = Animal in error
				# 99 = Undetermined
				unitInError = line[37:39]

				# Crash Date: MMDDYYYY
				crashDate = line[39:47]

				# Time Of Crash: military (2400 clock) time.
				crashTime = line[47:51]

				# Day Of Week: a number (sun = 1, sat = 7)
				dayOfWeek = line[51:52]

				# City Village or Township: Indicate type of governmental boundary. 
				# 1 = City
				# 2 = Village
				# 3 = Township
				cityVillageTownship = line[52:53]

				# FIPS Place Code: see FIPS reference table
				placeCodeFIPS = line[53:58]
		 
				# Name of City, Village, Township
				nameOfPlace = line[58:110]

				# County: See County Lookup Table 
				county = line[110:112]

				# latitude
				latitude = line[112:121]

				# longitude
				longitude = line[121:130]

				# Crash location prefix: If a street is divided into North/South, or East/West sections, the prefix is required.
				# N = North
				# S = South
				# E = East
				# W = West
				cardinalDirection = line[130:131]

				# Location Road Name
				roadName = line[131:159]

				# Location Road Type:
				# AL = Alley 
				# AV = Avenue
				# BL = Boulevard 
				# CR = Circle
				# CT = Court
				# DR = Drive
				# HE = Heights 
				# HW = Highway 
				# LA = Lane
				# PK = Parkway 
				# PI = Pike
				# PL = Place 
				# RD = Road 
				# SQ = Square 
				# ST = Street 
				# TE = Terrace 
				# TL = Trail 
				# WA = Way
				roadType = line[159:161]

				# Crash Location:
				# The intersection code to indicate where the crash occurred. 
				# 01 = Not an Intersection
				# 02 = Four-way Intersection
				# 03 = T-Intersection
				# 04 = Y-intersection
				# 05 = Traffic circle/roundabout 
				# 06 = Five-point, or more
				# 07 = On ramp
				# 08 = Off ramp
				# 09 = Crossover
				# 10 = Driveway
				# 11 = Railway grade crossing 
				# 12 =Shared-use paths or trails 
				# 99 Unknown
				crashLocation = line[201:203]



				# Location Of First Harmful Event:
				# 1 = On Roadway
				# 2 = On Shoulder
				# 3 = In Median
				# 4 = On Roadside
				# 5 = On Gore
				# 6 = Outside Trafficway
				# 9 = Unknown
				firstHarmfulLocation = line[203:204]

				#Road Contour:
				# 1 = Straight Level
				# 2 = Straight Grade
				# 3 = Curve Level
				# 4 = Curve Grade
				# 9 = Unknown
				roadContour = line[204:205]

				# Road Conditions - Primary:
				# Road conditions at crash scene. Primary is the overall road conditions at time of crash.
				# 01 = Dry 
				# 02 = Wet
				# 03 = Snow
				# 04 = Ice
				# 05 = Sand, Mud, Dirt, Oil, Gravel
				# 06 = Water (Standing, Moving)
				# 07 = Slush
				# 08 = Debris**
				# 09 = Rut, Holes, bumps, Uneven Pavement** 
				# 10 = Unknown, 
				# 99 = Unknown
				primaryRoadConditions = line[205:207]


				# Road Conditions - Secondary:
				# Road conditions at crash scene. Secondary is the location conditions that contributed to crash.
				# 01 = Dry
				# 02 = Wet
				# 03 = Snow
				# 04 = Ice
				# 05 = Sand, Mud, Dirt, Oil, Gravel 06 = Water (Standing, Moving) 07 = Slush
				# 08 = Debris**
				# 09 = Rut, Holes, bumps, Uneven Pavement** 10 = Other
				# 99 = Unknown
				# **Secondary Road Conditions Only
				secondaryRoadConditions = line[207:209]

				# Manner of Crash:
				# 1 = Not Collision Between Two Vehicles in Transport
				# 2 = Rear-end
				# 3 = Head-on
				# 4 = Rear-to-rear
				# 5 = Backing
				# 6 = Angle
				# 7 = Sideswipe, same direction
				# 8 = Sideswipe, opposite direction
				# 9 = Unknown
				mannerOfCrash = line[209:210]

				# Weather:
				# 1 = Clear
				# 2 = Cloudy
				# 3 = Fog, Smog, Smoke
				# 4 = Rain
				# 5 = Sleet, Hail (Freezing Rain Or Drizzle)
				# 6 = Snow
				# 7 = Severe Crosswinds
				# 8 = Blowing Sand, Soil, Dirt, Snow
				# 9 = Other/ Unknown
				weather = line[210:212]


				# Light Conditions - Primary:
				# Lighting conditions at the time of the crash. Primary is normal conditions.
				# 1 = Daylight
				# 2 = Dawn
				# 3 = Dusk
				# 4 = Dark - Lighted Roadway
				# 5 = Dark - Roadway Not Lighted
				# 6 = Dark - Unknown Roadway Lighting
				# 7 = Glare
				# 8 = Other
				# 9 = Unknown
				primaryLightConditions = line[212:213]

				# Light Conditions - Secondary
				# Lighting conditions at the time of the crash. Secondary is causative conditions.
				# 1 = Daylight
				# 2 = Dawn
				# 3 = Dusk
				# 4 = Dark - Lighted Roadway
				# 5 = Dark - Roadway Not Lighted
				# 6 = Dark - Unknown Roadway Lighting
				# 7 = Glare
				# 8 = Other
				# 9 = Unknown
				secondaryLightConditions = line[213:214]
				if (nameOfPlace[0:7] == "Jackson" or nameOfPlace[0:12] == "North Canton" or nameOfPlace[0:5] == "Plain"):
					clusterLocs.append([float(latitude),-float(longitude), (4-float(crashSeverity)) * (4-float(crashSeverity))])
					if (crashLocation == " 2" or crashLocation == " 3" or crashLocation == " 4" or crashLocation == " 5" or crashLocation == " 6"):
						newRow = [recordType, docNumber, locReport, crashSeverity, numUnits, crashDate, crashTime, nameOfPlace, latitude, longitude, roadName, crashLocation, roadContour, secondaryRoadConditions, mannerOfCrash, weather, secondaryLightConditions]
						#csvWriter.writerow(newRow)
						locationsRow = [latitude, -float(longitude)]
						
			distance_matrix = pairwise_distances(clusterLocs, metric=distance_in_meters)
			dbscan = DBSCAN(metric='precomputed', eps=40, min_samples=10)
			dbscan.fit(distance_matrix)
			labels = dbscan.labels_
			cores = dbscan.core_sample_indices_
			n_clusters = len(set(labels))
			dict = {k: [] for k in range(n_clusters)}
			sumval = 0
			for i in range(len(labels)):
				if labels[i] != -1:
					dict[labels[i]].append(clusterLocs[i])
					sumval+=1

			print sumval
			for key in dict:
				avglat = 0
				avglon = 0
				avgSeverity = 0
				for latlon in dict[key]:
					avglat += latlon[0]
					avglon += latlon[1]
					avgSeverity += latlon[2]
				if len(dict[key]) > 0:
					avglat = avglat / len(dict[key])
					avglon = avglon / len(dict[key])
					avgSeverity = avgSeverity / len(dict[key])
					writeString = [str(avglat),str(avglon)]
					csvLocationsWriter.writerow(writeString)
					newRow = [avglat, avglon, avgSeverity * len(dict[key])]
					csvWriter.writerow(newRow)











