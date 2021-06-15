local Wait          = Wait
local CreateThread  = CreateThread
local PlayerPedId   = PlayerPedId

-- Set Lang
i18n.setLang(Config.setLang)

-- ESX START
ESX = nil

CreateThread(function()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(250)
    end
end)

-- Opening the admin menu
RegisterCommand(Config.commandName, function()
    if Config.esxPerms then

    elseif Config.steamPerms then

    elseif Config.badgerPerms then

    elseif Config.debugPerms then
        openAdminMenu()
    end
end)

RegisterKeyMapping(Config.commandName, Config.commandDescription, 'keyboard', Config.commandKey)

-- Admin menu function
function openAdminMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'admin_menu', {
		title    = i18n.translate("admin_menu"),
		align    = Config.alignMenu,
		elements = {
			{label = i18n.translate("admin_options_label"), value = 'admin_options'},
			{label = "Players", value = 'players_options'}
	}}, function(data, menu)
		local actionValue = data.current.value
		if actionValue == 'admin_options' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'admin_options_menu', {
				title    = data.current.label,
				align    = Config.alignMenu,
				elements = {
					{label = i18n.translate("player_options_label"), value = 'player_options'},
					{label = i18n.translate("vehicle_options_label"), value = 'vehicle_options'},
					{label = i18n.translate("server_options_label"), value = 'server_options'}
			}}, function(data2, menu2)
				local actionValue2 = data2.current.value
				if actionValue2 == 'player_options' then
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_options_menu', {
						title    = data2.current.label,
						align    = Config.alignMenu,
						elements = {
							{label = i18n.translate("no_clip_label"), value = 'no_clip'},
							{label = i18n.translate("invincible_label"), value = 'invincible'},
							{label = i18n.translate("invisible_label"), value = 'invisible'},
							{label = i18n.translate("healArmor_label"), value = 'healArmor'},
							{label = i18n.translate("revive_label"), value = 'revive'},
							{label = i18n.translate("marker_label"), value = 'marker'},
							{label = i18n.translate("ped_label"), value = 'ped'}
					}}, function(data3, menu3)
						local actionValue3 = data3.current.value
						if actionValue3 == 'no_clip' then
							setPedNoclip()
						elseif actionValue3 == 'invincible' then
							setPedInvincible()
						elseif actionValue3 == 'invisible' then
							setPedInvisible()
						elseif actionValue3 == 'healArmor' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'heal_armor_menu', {
								title = i18n.translate("healArmor_menu_label"),
							}, function(data4, menu4)
								local actionValue4 = data4.value
								local ped, id = PlayerPedId(), PlayerId()
								if actionValue4 == "h" then 
									SetEntityHealth(ped, GetPedMaxHealth(ped))
								elseif actionValue4 == "s" then
									SetPedArmour(ped, GetPlayerMaxArmour(id))
								elseif actionValue4 == nil then
									SetEntityHealth(ped, GetPedMaxHealth(ped))
									SetPedArmour(ped, GetPlayerMaxArmour(id))
								end
								menu4.close()
							end, function(data4, menu4)
								menu4.close()
							end)
						elseif actionValue3 == 'revive' then
							local coords, heading = GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId())
							NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, false, false)
						elseif actionValue3 == 'marker' then
							teleportToMarker()
						elseif actionValue3 == 'ped' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ped_spawn_menu', {
								title = i18n.translate("ped_spawn_menu_label"),
							}, function(data4, menu4)
								local actionValue4 = data4.value
								if actionValue4 == "reset" then 
									setPlayerModel("mp_m_freemode_01")
								else
									setPlayerModel(actionValue4)
								end
								menu4.close()
							end, function(data4, menu4)
								menu4.close()
							end)
						end
					end, function(data3, menu3)
						menu3.close()
					end)
				elseif actionValue2 == 'vehicle_options' then
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_options_menu', {
						title    = data2.current.label,
						align    = Config.alignMenu,
						elements = {
							{label = i18n.translate("spawn_vehicle_label"), value = 'spawn_vehicle'},
							{label = i18n.translate("fix_vehicle_label"), value = 'fix_vehicle'},
							{label = i18n.translate("delete_vehicle_label"), value = 'delete_vehicle'},
							{label = i18n.translate("find_vehicle_label"), value = 'find_vehicle'},
							{label = i18n.translate("plate_vehicle_label"), value = 'plate_vehicle'}
					}}, function(data3, menu3)
						local actionValue3 = data3.current.value
						if actionValue3 == 'spawn_vehicle' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'veh_spawn_menu', {
								title = i18n.translate("spawn_vehicle_model_label"),
							}, function(data4, menu4)
								local actionValue4 = data4.value
								TriggerServerEvent('pe_admin:spawnVehicle', "source", tostring(actionValue4), "self")
								vehicleDelete()
								menu4.close()
							end, function(data4, menu4)
								menu4.close()
							end)
						elseif actionValue3 == 'fix_vehicle' then
							vehicleFix()
						elseif actionValue3 == 'delete_vehicle' then
							vehicleDelete()
						elseif actionValue3 == 'find_vehicle' then
							findVehicle()
						elseif actionValue3 == 'plate_vehicle' then
							if IsPedInAnyVehicle(PlayerPedId(), false) then
								ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'plate_changer_menu', {
									title = i18n.translate("plate_changer_label"),
								}, function(data4, menu4)
									local actionValue4 = data4.value
									SetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false), actionValue4)
									menu4.close()
								end, function(data4, menu4)
									menu4.close()
								end)
							else
								print("Not in Vehicle")
							end
						end
					end, function(data3, menu3)
						menu3.close()
					end)
				elseif actionValue2 == 'server_options' then
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'server_options_menu', {
						title    = data2.current.label,
						align    = Config.alignMenu,
						elements = {
							{label = i18n.translate("delete_all_label"), value = 'delete_all'},
							{label = i18n.translate("kick_all_label"), value = 'kick_all'},
							{label = i18n.translate("bring_all_label"), value = 'bring_all'},
							{label = i18n.translate("revive_all_label"), value = 'revive_all'},
							{label = i18n.translate("freeze_all_label"), value = 'freeze_all'},
							{label = i18n.translate("freeze_zone_label"), value = 'freeze_zone'},
							{label = i18n.translate("send_announcement_label"), value = 'send_announcement'}
					}}, function(data3, menu3)
						local actionValue3 = data3.current.value
						if actionValue3 == 'delete_all' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'delete_all_menu', {
								title = i18n.translate("delete_all_options_label"),
							}, function(data4, menu4)
								local actionValue4 = data4.value
								if actionValue4 == "veh" then
									TriggerServerEvent('pe_admin:delAll', "veh")
									menu4.close()
								elseif actionValue4 == "peds" then
									TriggerServerEvent('pe_admin:delAll', "peds")
									menu4.close()
								elseif actionValue4 == "obj" then
									TriggerServerEvent('pe_admin:delAll', "obj")
									menu4.close()
								elseif actionValue4 == "chat" then
									TriggerServerEvent('pe_admin:delAll', "chat")
									menu4.close()
								elseif actionValue4 == "all" then
									menu4.close()
									ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'delete_all_question_menu', {
										title = i18n.translate("delete_all_question_label"),
									}, function(data5, menu5)
										local actionValue5 = data5.value
										if actionValue5 == "yes" then
											TriggerServerEvent('pe_admin:delAll', "veh")
											TriggerServerEvent('pe_admin:delAll', "peds")
											TriggerServerEvent('pe_admin:delAll', "obj")
											if Config.tNotify then
        
											elseif Config.esxNotify then
									
											elseif Config.debugNotify then
												print("Deleted all")
											end
											menu5.close()
										elseif actionValue5 == "no" then
											TriggerServerEvent('pe_admin:delAll', "veh")
											TriggerServerEvent('pe_admin:delAll', "peds")
											if Config.tNotify then
        
											elseif Config.esxNotify then
									
											elseif Config.debugNotify then
												print("Deleted veh and peds")
											end
											menu5.close()
										elseif actionValue5 ~= nil then
											if Config.tNotify then
        
											elseif Config.esxNotify then
									
											elseif Config.debugNotify then
												print("Wrong option")
											end
										end
									end, function(data5, menu5)
										menu5.close()
									end)
								elseif actionValue4 ~= nil then
									if Config.tNotify then

									elseif Config.esxNotify then
							
									elseif Config.debugNotify then
										print("Wrong option")
									end
								end
							end, function(data4, menu4)
								menu4.close()
							end)
						elseif actionValue3 == 'kick_all' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'kick_all_menu', {
								title = i18n.translate("kick_all_label_message"),
							}, function(data4, menu4)
								local actionValue4 = data4.value
								if actionValue4 == "no" or actionValue4 == nil then
									TriggerServerEvent('pe_admin:kickAll')
								else
									TriggerServerEvent('pe_admin:kickAll', actionValue4)
								end
							end, function(data4, menu4)
								menu4.close()
							end)
						elseif actionValue3 == 'bring_all' then
							TriggerServerEvent('pe_admin:bringAll')
						elseif actionValue3 == 'revive_all' then
							TriggerServerEvent('pe_admin:reviveAll')
						elseif actionValue3 == 'freeze_all' then
							TriggerServerEvent('pe_admin:freezeAll')
						elseif actionValue3 == 'freeze_zone' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'freeze_zone_ask_menu', {
								title = i18n.translate("freeze_zone_ask_label"),
							}, function(data4, menu4)
								local actionValue4 = tostring(data4.value)
								if actionValue4 ~= nil and actionValue4 == "yes" then
									menu4.close()
									TriggerServerEvent('pe_admin:freezeZone', false, nil, nil, nil, nil)
								elseif actionValue4 == "no" then
									menu4.close()
									ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'freeze_zone_x_menu', {
										title = i18n.translate("freeze_zone_x_label"),
									}, function(data5, menu5)
										local actionValue5 = tonumber(data5.value)
										if actionValue5 ~= nil and type(actionValue5) == "number" then
											menu5.close()
											ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'freeze_zone_question_menu', {
												title = i18n.translate("freeze_zone_question_label"),
											}, function(data6, menu6)
												local actionValue6 = tostring(data6.value)
												if actionValue6 == "yes" then
													actionValue5 = actionValue5 * -1
												elseif actionValue6 == "no" then
													actionValue5 = actionValue5
												end
												if actionValue6 ~= nil and type(actionValue6) == "string" then
													menu6.close()
													ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'freeze_zone_y_menu', {
														title = i18n.translate("freeze_zone_y_label"),
													}, function(data7, menu7)
														local actionValue7 = tonumber(data7.value)
														if actionValue7 ~= nil and type(actionValue7) == "number" then
															menu7.close()
															ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'freeze_zone_question_menu', {
																title = i18n.translate("freeze_zone_question_label"),
															}, function(data8, menu8)
																local actionValue8 = tostring(data8.value)
																if actionValue8 == "yes" then
																	actionValue7 = actionValue7 * -1
																elseif actionValue8 == "no" then
																	actionValue7 = actionValue7
																end
																if actionValue8 ~= nil and type(actionValue8) == "string" then
																	menu8.close()
																	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'freeze_zone_z_menu', {
																		title = i18n.translate("freeze_zone_z_label"),
																	}, function(data9, menu9)
																		local actionValue9 = tonumber(data9.value)
																		if actionValue9 ~= nil and type(actionValue9) == "number" then
																			menu9.close()
																			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'freeze_zone_question_menu', {
																				title = i18n.translate("freeze_zone_question_label"),
																			}, function(data10, menu10)
																				local actionValue10 = tostring(data10.value)
																				if actionValue10 == "yes" then
																					actionValue9 = actionValue9 * -1
																				elseif actionValue10 == "no" then
																					actionValue9 = actionValue9
																				end
																				if actionValue10 ~= nil and type(actionValue10) == "string" then
																					menu10.close()
																					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'freeze_zone_radius_menu', {
																						title = i18n.translate("freeze_zone_radius_label"),
																					}, function(data11, menu11)
																						local actionValue11 = tonumber(data11.value)
																						if actionValue11 ~= nil and type(actionValue11) == "number" then
																							menu11.close()
																							TriggerServerEvent('pe_admin:freezeZone', true, actionValue5, actionValue7, actionValue9, actionValue11)
																						else
																							if Config.tNotify then
																					
																							elseif Config.esxNotify then
																					
																							elseif Config.debugNotify then
																								print("Not a number")
																							end
																						end
																					end, function(data11, menu11)
																						menu11.close()
																					end)
																				else
																					if Config.tNotify then
																			
																					elseif Config.esxNotify then
																			
																					elseif Config.debugNotify then
																						print("Not a number")
																					end
																				end
																			end, function(data10, menu10)
																				menu10.close()
																			end)
																		else
																			if Config.tNotify then
																	
																			elseif Config.esxNotify then
																	
																			elseif Config.debugNotify then
																				print("Not a number")
																			end
																		end
																	end, function(data9, menu9)
																		menu9.close()
																	end)
																else
																	if Config.tNotify then
															
																	elseif Config.esxNotify then
															
																	elseif Config.debugNotify then
																		print("Not a number")
																	end
																end
															end, function(data8, menu8)
																menu8.close()
															end)
														else
															if Config.tNotify then
													
															elseif Config.esxNotify then
													
															elseif Config.debugNotify then
																print("Not a number")
															end
														end
													end, function(data7, menu7)
														menu7.close()
													end)
													menu6.close()
												else
													if Config.tNotify then
											
													elseif Config.esxNotify then
											
													elseif Config.debugNotify then
														print("Not a number")
													end
												end
											end, function(data6, menu6)
												menu6.close()
											end)
										else
											if Config.tNotify then
									
											elseif Config.esxNotify then
									
											elseif Config.debugNotify then
												print("Not a number")
											end
										end
									end, function(data5, menu5)
										menu5.close()
									end)
								else
									if Config.tNotify then

									elseif Config.esxNotify then
							
									elseif Config.debugNotify then
										print("Not a string")
									end
								end
							end, function(data4, menu4)
								menu4.close()
							end)
						elseif actionValue3 == 'send_announcement' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'announcement_title_menu', {
								title = i18n.translate("announcement_title_label"),
							}, function(data4, menu4)
								local actionValue4 = data4.value
								if actionValue4 ~= nil then
									menu4.close()
									ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'announcement_message_menu', {
										title = i18n.translate("announcement_message_label"),
									}, function(data5, menu5)
									local actionValue5 = data5.value
									if actionValue5 ~= nil then
										menu5.close()
										ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'announcement_time_menu', {
											title = i18n.translate("announcement_time_label"),
										}, function(data6, menu6)
											local actionValue6 = data6.value
											if type(tonumber(actionValue6)) == "number" then
												TriggerServerEvent('pe_admin:sendAnnouncement', actionValue4, actionValue5, actionValue6)
												menu6.close()
											else
												if Config.tNotify then

												elseif Config.esxNotify then
													
												elseif Config.debugNotify then
													print("No values or it is not a number")
												end
											end
										end, function(data6, menu6)
											menu6.close()
										end)
									else
										if Config.tNotify then

										elseif Config.esxNotify then
								
										elseif Config.debugNotify then
											print("No values")
										end
									end
									end, function(data5, menu5)
										menu5.close()
									end)
								else
									if Config.tNotify then

									elseif Config.esxNotify then
							
									elseif Config.debugNotify then
										print("No values")
									end
								end
							end, function(data4, menu4)
								menu4.close()
							end)
						end
					end, function(data3, menu3)
						menu3.close()
					end)
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif actionValue == 'players_options' then
			ESX.TriggerServerCallback('pe_admin:playersOnline', function(players)
				local elements = {}
				for i=1, #players, 1 do
					table.insert(elements, {
						label 	= players[i].name .." | ID: " .. players[i].source .. " | Perms: " ,
						value 	= players[i].source,
						name	= players[i].name,
						health	= players[i].health,
						armor	= players[i].armor
					})
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_list_menu', {
					title    = data.current.label,
					align    = Config.alignMenu,
					elements = elements
				}, function(data2, menu2)
					local targetSource = data2.current.value
					local targetLabel = data2.current.info
					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'players_options_menu', {
						title    = "ID: " .. targetSource .. " | H: " .. data2.current.health .. " | S: " .. data2.current.armor,
						align    = Config.alignMenu,
						elements = {
							{label = i18n.translate("revive_player_label"), value = 'revive_player'},
							{label = i18n.translate("kill_player_label"), value = 'kill_player'},
							{label = i18n.translate("freeze_player_label"), value = 'freeze_player'},
							{label = i18n.translate("give_vehicle_player_label"), value = 'give_vehicle_player'},
							{label = i18n.translate("teleport_label"), value = 'teleport_player'},
							{label = i18n.translate("bring_label"), value = 'bring_player'},
							{label = i18n.translate("kick_label"), value = 'kick_player'},
							{label = i18n.translate("giveweapon_label"), value = 'giveweapon_player'},
							{label = i18n.translate("get_info_label"), value = 'get_info'},
					}}, function(data3, menu3)
						local actionValue3 = data3.current.value
						if actionValue3 == 'revive_player' then
							TriggerServerEvent('pe_admin:reviveHealTarget', targetSource, "revive")
						elseif actionValue3 == 'kill_player' then
							TriggerServerEvent('pe_admin:reviveHealTarget', targetSource, "kill")
						elseif actionValue3 == 'freeze_player' then
							TriggerServerEvent('pe_admin:freezeTarget', targetSource)
						elseif actionValue3 == 'give_vehicle_player' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'veh_spawn_menu', {
								title = i18n.translate("spawn_vehicle_model_label"),
							}, function(data4, menu4)
								local actionValue4 = data4.value
								TriggerServerEvent('pe_admin:spawnVehicle', targetSource, tostring(actionValue4), "target")
								menu4.close()
							end, function(data4, menu4)
								menu4.close()
							end)
						elseif actionValue3 == 'teleport_player' then
							TriggerServerEvent('pe_admin:tpToTarget', targetSource)
						elseif actionValue3 == 'bring_player' then
							TriggerServerEvent('pe_admin:tpTarget', targetSource)
						elseif actionValue3 == 'kick_player' then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'kick_player_menu', {
								title = i18n.translate("kick_player_label"),
							}, function(data4, menu4)
								local actionValue4 = data4.value
								if actionValue4 == "no" or actionValue4 == nil then
									TriggerServerEvent('pe_admin:kickTarget', targetSource)
									menu4.close()
								else
									TriggerServerEvent('pe_admin:kickTarget', targetSource, actionValue4)
									menu4.close()
								end
								menu4.close()
							end, function(data4, menu4)
								menu4.close()
							end)
						elseif actionValue3 == 'giveweapon_player' then
							menu3.close()
							local allWeapons = Config.allWeapons
							local elementos = {}
							for i=1, #allWeapons, 1 do
								table.insert(elementos, {
									label 	= allWeapons[i].label,
									value 	= allWeapons[i].value
								})
							end
							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'weapon_men', {
								title    = "test",
								align    = Config.alignMenu,
								elements = elementos
							}, function(data4, menu4)
								if data4.current.value then
									print(data4.current.value)
									menu4.close()
								end
							end, function(data4, menu4)
								menu4.close()
							end)
						elseif actionValue3 == 'get_info' then
							TriggerServerEvent('pe_admin:getInformation', targetSource)
						end
					end, function(data3, menu3)
						menu3.close()
					end)
				end, function(data2, menu2)
					menu2.close()
				end)
			end)
        end
    end, function(data, menu)
		menu.close()
	end)
end

-- Close menu if restarted
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		ESX.UI.Menu.CloseAll()
	end
end)
