extends Panel

var tower
var upgrade
var nameOfSpecialTower = ''

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask==1:
		pass
	elif event is InputEventMouseMotion and event.button_mask==1:
		pass
	elif event is InputEventMouseButton and event.button_mask==0:
		if !event.pressed:
			#print("UPGRADE BUTTON CLICKED FOR TOWER ",tower.displayName)
			if(int(upgrade["cost"])<=int($"../../../HealthAndMoney".Money)):
				$"../../../HealthAndMoney".changeMoney(upgrade["cost"])
				tower.upgradeOnce(nameOfSpecialTower)
				if nameOfSpecialTower == '':
					$'../../../'.changeToUpgradeScreen(tower,tower.upgrades)
					#update the panel to relfect upgrade, given its not a 
					#tower replacement upgrade
				
				queue_free() #remove this from the panel
				
			else:
				print("HEY SHITASS YOU CANNOT AFFORD THIS")


		
		
