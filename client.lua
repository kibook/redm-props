local CurrentProp

function PlayAnimation(ped, dict, name, flag)
	if not DoesAnimDictExist(dict) then
		return
	end

	RequestAnimDict(dict)

	while not HasAnimDictLoaded(dict) do
		Wait(0)
	end

	TaskPlayAnim(ped, dict, name, 1.0, 1.0, -1, flag, 0, false, false, false, '', false)

	RemoveAnimDict(dict)
end

function CreateProp()
	CurrentProp.handle = CreateObjectNoOffset(GetHashKey(CurrentProp.model), 0.0, 0.0, 0.0, true, false, false, false)
end

function AttachProp(ped)
	local handle = CurrentProp.handle
	local bone = CurrentProp.bone
	local x = CurrentProp.x
	local y = CurrentProp.y
	local z = CurrentProp.z
	local pitch = CurrentProp.pitch
	local roll = CurrentProp.roll
	local yaw = CurrentProp.yaw

	if type(bone) == 'string' then
		bone = GetEntityBoneIndexByName(ped, bone)
	end

	AttachEntityToEntity(handle, ped, bone, x, y, z, pitch, roll, yaw, false, false, true, false, 0, true, false, false)
end

function StartUsingProp(name)
	if CurrentProp then
		StopUsingProp()
	end

	CurrentProp = Config.Props[name]
end

function StopUsingProp()
	if not CurrentProp then
		return
	end

	local prop = CurrentProp
	CurrentProp = nil

	local ped = PlayerPedId()

	DetachEntity(prop.handle)
	DeleteObject(prop.handle)

	StopAnimTask(ped, prop.animation.dict, prop.animation.name)
end

function PropCommand(source, args, raw)
	if args[1] then
		StartUsingProp(args[1])
	else
		StopUsingProp()
	end
end

RegisterCommand('p', PropCommand)

AddEventHandler('onResourceStop', function(resource)
	if GetCurrentResourceName() ~= resource then
		return
	end

	if CurrentProp then
		StopUsingProp()
	end
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/p', 'Use a prop emote', {
		{name = 'prop', help = 'Prop emote to use, or omit to cancel the current prop emote'}
	})

	while true do
		Wait(500)

		if CurrentProp then
			local ped = PlayerPedId()
			local anim = CurrentProp.animation

			if not IsEntityPlayingAnim(ped, anim.dict, anim.name, anim.flag) then
				PlayAnimation(ped, anim.dict, anim.name, anim.flag)
			end

			if not (CurrentProp.handle and DoesEntityExist(CurrentProp.handle)) then
				CreateProp()
				AttachProp(ped)
			elseif not IsEntityAttachedToEntity(CurrentProp.handle, ped) then
				AttachProp(ped)
			end
		end
	end
end)
