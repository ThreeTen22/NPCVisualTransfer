Scriptname VNPC_UpdateCharacter extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.AllowPCDialogue(true)
	akTarget.QueueNiNodeUpdate()
EndEvent

