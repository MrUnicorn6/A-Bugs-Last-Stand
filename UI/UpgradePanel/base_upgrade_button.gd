extends Panel

var tower
var upgrade

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
				tower.upgradeOnce()
				$'../../../'.changeToUpgradeScreen(tower,tower.upgrades)#update 
				#the panel to reflect upgrade
				queue_free() #remove this from the panel
				
			else:
				print("HEY SHITASS YOU CANNOT AFFORD THIS")


		
		
