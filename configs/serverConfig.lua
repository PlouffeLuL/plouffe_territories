Auth = exports.plouffe_lib:Get("Auth")

local randomModels = {
	joaat('a_f_m_bodybuild_01'),
	joaat('a_f_m_prolhost_01'),
	joaat('a_f_o_salton_01'),
	joaat('a_f_y_business_03'),
	joaat('a_f_y_hipster_02'),
	joaat('a_m_m_malibu_01'),
	joaat('a_m_o_soucent_02'),
	joaat('a_m_o_soucent_03'),
	joaat('a_m_o_genstreet_01'),
	joaat('a_m_y_motox_01'),
	joaat('a_m_y_motox_02'),
	joaat('a_m_y_musclbeac_01'),
	joaat('a_m_y_salton_01'),
	joaat('a_m_y_yoga_01'),
	joaat('a_m_y_smartcaspat_01'),
	joaat('a_m_y_surfer_01'),
	joaat('a_m_y_soucent_01'),
	joaat('a_m_y_runner_01'),
	joaat('csb_undercover')
}

Server = {
	ready = false,
}

Tr = {}

Tr.Utils = {
	ped = 0,
	pedCoords = vector3(0,0,0)
}

Tr.Gangs = {
	default = {
		color = 0,
		ped = randomModels[math.random(1, #randomModels)],
		variations = {
			'a_f_m_bodybuild_01',
			'a_f_m_prolhost_01',
			'a_f_o_salton_01',
			'a_f_y_business_03',
			'a_f_y_hipster_02',
			'a_m_m_malibu_01',
			'a_m_o_soucent_02',
			'a_m_o_soucent_03',
			'a_m_o_genstreet_01',
			'a_m_y_motox_01',
			'a_m_y_motox_02',
			'a_m_y_musclbeac_01',
			'a_m_y_salton_01',
			'a_m_y_yoga_01',
			'a_m_y_smartcaspat_01',
			'a_m_y_surfer_01',
			'a_m_y_soucent_01',
			'a_m_y_runner_01',
			'csb_undercover'
		}
	},
	ballas = {
		color = 7,
		ped = "g_m_y_ballasout_01",
		variations = {
			"csb_ballasog",
			"g_f_y_ballas_01",
			"g_m_y_ballasout_01",
			"ig_ballasog"
		}
	},
	vagos = {
		color = 5,
		ped = "g_m_y_mexgoon_01",
		variations = {
			"g_m_y_mexgoon_01",
			"g_f_y_vagos_01",
			"a_m_y_mexthug_01",
			"csb_ramp_mex",
			"g_m_m_mexboss_02",
			"g_m_y_mexgang_01",
			"g_m_y_mexgoon_02",
			"g_m_y_mexgoon_03"
		}
	},
	aztecas = {
		color = 43,
		ped = "g_m_y_azteca_01",
		variations = {
			"g_m_y_azteca_01"
		}
	},
	marabuntas = {
		color = 3,
		ped = "g_m_y_salvagoon_01",
		variations = {
			"g_m_y_salvagoon_01",
			"g_m_y_salvaboss_01",
			"g_m_y_salvagoon_02", 
			"g_m_y_salvagoon_03",
			"g_m_y_strpunk_01",
			"g_m_y_strpunk_02"
		}
	},
	bsg = {
		color = 47,
		ped = "u_m_y_prisoner_01",
		variations = {
			"s_m_y_prismuscl_01",
			"u_m_y_prisoner_01",
			"s_m_y_prisoner_01",
			"u_m_y_prisoner_01",
			"s_f_y_baywatch_01",
			"csb_rashcosvki",
			"a_m_m_stlat_02"
		}
	},
	families = {
		color = 25,
		ped = "g_m_y_famca_01",
		variations = {
			"g_f_y_families_01",
			"g_m_y_famca_01",
			"g_m_y_famdnf_01",
			"g_m_y_famfor_01"
		}
	},
	sinister = {
		color = 40,
		ped = "g_m_y_lost_01",
		variations = {
			"g_m_y_lost_02",
			"g_m_y_lost_01",
			"g_m_y_lost_03",
			"g_f_y_lost_01"
		}
	},
}

Tr.Territories = {
	ballas = {
		label = "Ballas",
		highValue = {
			spawn = vector3(104.76650238037, -1939.3204345703, 20.803609848022),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(64.112365722656, -1819.7425537109, 25.139589309692),
			color = 7,
			width = 200.0, 
            height = 400.0,
			rotation = 51
		},
		coords = {
			ballas_territory = {
				box = {
					vector2(263.64764404297, -1871.40234375),
					vector2(137.72752380371, -2042.4847412109),
					vector2(-145.03010559082, -1757.5593261719),
					vector2(-35.454303741455, -1619.4735107422)
				}
			},

			ballas_stash = {
				coords = vector3(-2.9811007976532, -1821.4926757813, 29.543237686157),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "OpenStash", stash = "ballas_stash"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(-2.9811007976532, -1821.4926757813, 29.543237686157),
					heading = 230.0707244873,
					model = 'ig_marnie', 
				}
			},

			ballas_Shop = {
				coords = vector3(109.28855133057, -1797.6396484375, 27.075819015503),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "OpenShop", shop = "Ballas_Territory_Shop"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(109.28855133057, -1797.6396484375, 27.075819015503),
					heading = 139.15155029297,
					model = 'ig_marnie', 
				}
			}
		}
	},

	vagos = {
		label = "Vagos",
		highValue = {
			spawn = vector3(320.66470336914, -2027.9349365234, 20.736289978027),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(379.03787231445, -1982.5048828125, 24.192209243774),
			color = 5,
			width = 350.0, 
            height = 295.0,
			rotation = 51
		},
		coords = {
			vagos_territory = {
				box = {
					vector2(380.54940795898, -1770.8229980469),
					vector2(166.25175476074, -2025.7058105469),
					vector2(411.30908203125, -2210.9794921875),
					vector2(603.26531982422, -1949.732421875)
				}
			},

			vagos_stash = {
				coords = vector3(446.20913696289, -1972.7113037109, 23.169301986694),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "OpenStash", stash = "vagos_stash"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(446.20913696289, -1972.7113037109, 23.169301986694),
					heading = 313.77386474609,
					model = 'ig_marnie', 
				}
			},
		}
	},

	aztecas = {
		label = "Aztecas",
		highValue = {
			spawn = vector3(525.76403808594, -1761.1420898438, 28.692266464233),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(553.15307617188, -1715.3359375, 29.392520904541),
			color = 43,
			width = 285.0, 
            height = 229.5,
			rotation = 51
		},
		coords = {
			aztecas_territory = {
				box = {
					vector2(549.31109619141, -1888.8880615234),
					vector2(386.01779174805, -1747.0090332031),
					vector2(554.40405273438, -1532.3344726563),
					vector2(728.64801025391, -1676.5554199219)
				}
			}
		}
	},

	bsg = {
		label = "Bsg",
		highValue = {
			spawn = vector3(165.97930908203, -1729.1954345703, 29.291751861572),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(218.12829589844, -1628.8134765625, 29.222471237183),
			color = 47,
			width = 290.7, 
            height = 400.7,
			rotation = 51
		},
		coords = {
			bsg_territory = {
				box = {
					vector2(285.08221435547, -1849.9183349609),
					vector2(-20.374320983887, -1597.6125488281),
					vector2(154.96559143066, -1386.9499511719),
					vector2(461.12948608398, -1643.1842041016)
				}
			},

			bsg_stash = {
				coords = vector3(294.64111328125, -1715.5115966797, 29.193555831909),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "OpenStash", stash = "bsg_stash"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(294.64111328125, -1715.5115966797, 29.193555831909),
					heading = 230.51736450195,
					model = 'ig_marnie', 
				}
			},
		}
	},

	families = {
		label = "Families",
		highValue = {
			spawn = vector3(-127.64701843262, -1620.7551269531, 32.030521392822),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(-113.1171875, -1577.8884277344, 37.407787322998),
			color = 25,
			width = 353.5, 
            height = 181.0,
			rotation = 51
		},
		coords = {
			families_territory = {
				box = {
					vector2(-73.157615661621, -1385.2833251953),
					vector2(59.767501831055, -1495.5302734375),
					vector2(-161.56999206543, -1762.7883300781),
					vector2(-286.09091186523, -1659.4412841797)
				}
			},

			families_stash = {
				coords = vector3(-255.95216369629, -1542.8509521484, 31.915037155151),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "OpenStash", stash = "families_stash"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(-255.95216369629, -1542.8509521484, 31.915037155151),
					heading = 219.5986328125,
					model = 'ig_marnie', 
				}
			},
		}
	},

	bennys = {
		label = "Bennys",
		highValue = {
			spawn = vector3(-201.58277893066, -1303.3604736328, 31.261444091797),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(-243.35353088379, -1326.7320556641, 31.411354064941),
			color = 85,
			width = 260.0, 
            height = 190.0,
			rotation = 0
		},
		coords = {
			bennys_territory = {
				box = {
					vector2(-117.86954498291, -1417.7379150391),
					vector2(-116.36389923096, -1234.1663818359),
					vector2(-369.1589050293, -1232.7615966797),
					vector2(-371.81219482422, -1417.5081787109)
				}
			},

			bennys_shop = {
				coords = vector3(-195.63145446777, -1315.6794433594, 31.089345932007),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "OpenShop", shop = "bennys_shop"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(-195.63145446777, -1315.6794433594, 31.089345932007),
					heading = 93.429069519043,
					model = 'ig_marnie', 
				}
			},
		}
	},

	hood_hospital = {
		label = "Hopital",
		highValue = {
			spawn = vector3(424.32818603516, -1337.2951660156, 45.983364105225),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(391.29437255859, -1416.7613525391, 31.01699256897),
			color = 85,
			width = 258.0, 
            height = 400.0,
			rotation = 51
		},
		coords = {
			hood_hospital_territory = {
				box = {
					vector2(320.65615844727, -1198.9379882813),
					vector2(164.7410736084, -1392.8645019531),
					vector2(465.46661376953, -1638.5220947266),
					vector2(616.67535400391, -1443.4608154297)
				}
			},

			hood_hospital_Shop = {
				coords = vector3(454.46942138672, -1497.2822265625, 28.18815612793),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "OpenShop", shop = "hood_hospital_Shop"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(454.46942138672, -1497.2822265625, 28.18815612793),
					heading = 196.4451751709,
					model = 'ig_marnie', 
				}
			},
		}
	},

	industriel_bottom = {
		label = "Industriel sud",
		highValue = {
			spawn = vector3(851.93743896484, -2345.5749511719, 30.331642150879),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(914.17071533203, -2278.240234375, 30.555734634399),
			color = 85,
			width = 365.0, 
            height = 397.0,
			rotation = -5
		},
		coords = {
			industriel_bottom_territory = {
				box = {
					vector2(1073.1319580078, -2485.611328125),
					vector2(1098.2845458984, -2092.0153808594),
					vector2(743.58081054688, -2073.2268066406),
					vector2(711.10198974609, -2467.1818847656)
				}
			},

			industriel_bottom_requestTrain = {
				coords = vector3(773.37927246094, -2480.880859375, 20.290090560913),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "TrainRobbery"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(773.37927246094, -2480.880859375, 20.290090560913),
					heading = 262.33096313477,
					model = 'ig_marnie', 
				}
			}
		}
	},

	industriel_mid = {
		label = "Industriel central",
		highValue = {
			spawn = vector3(981.52978515625, -1827.2071533203, 31.219717025757),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(945.79095458984, -1912.3641357422, 31.165925979614),
			color = 85,
			width = 365.0, 
            height = 337.0,
			rotation = -5
		},
		coords = {
			industriel_mid_territory = {
				box = {
					vector2(1103.0354003906, -2081.3046875),
					vector2(741.56658935547, -2060.0666503906),
					vector2(771.87023925781, -1742.0367431641),
					vector2(1137.5659179688, -1762.8520507813)
				}
			},

			industriel_mid_Shop = {
				coords = vector3(849.61633300781, -1995.6593017578, 29.980081558228),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "OpenShop", shop = "industriel_mid_Shop"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(849.61633300781, -1995.6593017578, 29.980081558228),
					heading = 358.63235473633,
					model = 'ig_marnie', 
				}
			},
		}
	},

	industriel_top = {
		label = "Industriel nord",
		highValue = {
			spawn = vector3(921.25256347656, -1576.0439453125, 30.61417388916),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(972.14611816406, -1599.3920898438, 30.188608169556),
			color = 85,
			width = 270.0, 
            height = 289.0,
			rotation = -5
		},
		coords = {
			industriel_top_territory = {
				box = {
					vector2(856.84411621094, -1448.2864990234),
					vector2(1121.7807617188, -1473.3583984375),
					vector2(1099.6955566406, -1752.1134033203),
					vector2(830.38854980469, -1725.5216064453)
				}
			},

			industriel_top_workbench = {
				coords = vector3(948.81402587891, -1513.7047119141, 30.962684631348),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Workbench",
				aditionalParams = {territory = "industriel_top", zone = "industriel_top_workbench"},
				zoneMap = {
					inEvent = "plouffe_territories:craftBench:in",
					outEvent = "plouffe_territories:craftBench:out",
				}
			},
		}
	},

	marabunta = {
		label = "Marabunta",
		highValue = {
			spawn = vector3(1433.3128662109, -1499.8360595703, 63.184337615967),
		},
		drugs = {
			ounceweed = {
				name = "ounceweed",
				price = math.random(80,120),
				amount = 1
			}
		},
		blip = {
			coords = vector3(1324.07421875, -1672.84375, 58.182285308838),
			color = 85,
			width = 365.0, 
            height = 260.0,
			rotation = 20
		},
		coords = {
			marabunta_territory = {
				box = {
					vector2(1451.7976074219, -1488.0808105469),
					vector2(1539.0385742188, -1728.4228515625),
					vector2(1186.3989257813, -1846.6541748047),
					vector2(1104.7071533203, -1623.7144775391)
				}
			},

			marabunta_stash = {
				coords = vector3(1259.0645751953, -1564.6977539063, 54.551708221436),
				maxDst = 1.5,
				isZone = true,
				nuiLabel = "Intéragir",
				aditionalParams = {fnc = "OpenStash", stash = "marabunta_stash"},
				keyMap = {
					onRelease = true,
					releaseEvent = "plouffe_territories:onZone",
					key = "E"
				},
				pedInfo = {
					coords = vector3(1259.0645751953, -1564.6977539063, 54.551708221436),
					heading = 216.00881958008,
					model = 'ig_marnie', 
				}
			},
		}
	}
}

Tr.StashItems = {
	add = {
		{
			name = "weed",
			amount = {min = 10, max = 100},
			chances = 10,
			metadata = {}
		},
		{
			name = "methkit", 
			amount = {min = 1, max = 3},
			chances = 10,
			metadata = {}
		},
		{
			name = "lithium,", 
			amount = {min = 1, max = 10},
			chances = 10,
			metadata = {}
		}
	},
	exchange = {
		black_money = {
			amount = 10,
			items = {
				{
					name = "money",
					amount = 5
				}
			}
		}
	}
}

Tr.Craftables = {
	WEAPON_GLOCK19X2 = {
		required = {
			plastic = {amount = 1000, label = ""},
			steel = {amount = 1000, label = ""},
			allum = {amount = 1000, label = ""}
		}
	},

	WEAPON_DP9 = {
		required = {
			plastic = {amount = 1000, label = ""},
			steel = {amount = 1000, label = ""},
			allum = {amount = 1000, label = ""}
		}
	},

	WEAPON_BROWNING = {
		required = {
			plastic = {amount = 1000, label = ""},
			steel = {amount = 1000, label = ""},
			allum = {amount = 1000, label = ""}
		}
	},

	WEAPON_SCORPIONEVO = {
		required = {
			plastic = {amount = 2000, label = ""},
			steel = {amount = 2000, label = ""},
			allum = {amount = 2000, label = ""}
		}
	},

	WEAPON_MP9A = {
		required = {
			plastic = {amount = 2000, label = ""},
			steel = {amount = 2000, label = ""},
			allum = {amount = 2000, label = ""}
		}
	},

	WEAPON_GLOCK18C = {
		required = {
			plastic = {amount = 2000, label = ""},
			steel = {amount = 2000, label = ""},
			allum = {amount = 2000, label = ""}
		}
	},

	WEAPON_DRACO = {
		required = {
			plastic = {amount = 2500, label = ""},
			steel = {amount = 2500, label = ""},
			allum = {amount = 2500, label = ""}
		}
	},

	WEAPON_AKS74U = {
		required = {
			plastic = {amount = 3000, label = ""},
			steel = {amount = 3000, label = ""},
			allum = {amount = 3000, label = ""}
		}
	},

	WEAPON_P90FM = {
		required = {
			plastic = {amount = 3000, label = ""},
			steel = {amount = 3000, label = ""},
			allum = {amount = 3000, label = ""}
		}
	},

	WEAPON_MPX = {
		required = {
			plastic = {amount = 3000, label = ""},
			steel = {amount = 3000, label = ""},
			allum = {amount = 3000, label = ""}
		}
	},

	WEAPON_SCARSC = {
		required = {
			plastic = {amount = 3000, label = ""},
			steel = {amount = 3000, label = ""},
			allum = {amount = 3000, label = ""}
		}
	},

	WEAPON_PMXFM = {
		required = {
			plastic = {amount = 3000, label = ""},
			steel = {amount = 3000, label = ""},
			allum = {amount = 3000, label = ""}
		}
	},

	WEAPON_P320B = {
		required = {
			plastic = {amount = 1000, label = ""},
			steel = {amount = 1000, label = ""},
			allum = {amount = 1000, label = ""}
		}
	},

	WEAPON_M45A1 = {
		required = {
			plastic = {amount = 1000, label = ""},
			steel = {amount = 1000, label = ""},
			allum = {amount = 1000, label = ""}
		}
	},

	lockpick = {
		required = {
			plastic = {amount = 150, label = ""},
			steel = {amount = 150, label = ""}
		}
	},

	advancedlockpick = {
		required = {
			plastic = {amount = 500, label = ""},
			steel = {amount = 500, label = ""}
		}
	}
}

Tr.HighValue = {}