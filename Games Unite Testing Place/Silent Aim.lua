local Camera = workspace.CurrentCamera
local UserInputService = game:GetService('UserInputService')

local Client = {}
do
    for _, v in next, getgc(true) do
        if (type(v) == 'table') then
            if (rawget(v, 'Fire') and type(rawget(v, 'Fire')) == 'function' and not Client.Bullet) then
                Client.Bullet = v
            elseif (rawget(v, 'HiddenUpdate')) then
                Client.Players = debug.getupvalue(rawget(v, 'new'), 9)
            end
        end
    end
    
    function Client:GetPlayerHitbox(player, hitbox)
        for _, player_hitbox in next, player.Hitboxes do
            if (player_hitbox._name == hitbox) then
                return player_hitbox
            end
        end
    end
    function Client:GetClosestPlayerFromCursor()
        local nearest_player, distance = nil, math.huge
    
        for _, player in next, Client.Players do
            pcall(function()
                if (
                    not player.Dead and
                    player.PlayerModel and
                    player.PlayerModel.Model.Head.Transparency == 0
                ) then
                    pos, bounds = Camera:WorldToViewportPoint(player.Position)
    
                    if bounds then
                        local magnitude = (UserInputService:GetMouseLocation() - Vector2.new(pos.X, pos.Y)).Magnitude
                        if (magnitude < distance) then
                            distance = magnitude
                            nearest_player = player
                        end
                    end  
                end
            end)
        end 
        return nearest_player
    end
end

Fire = hookfunction(Client.Bullet.Fire, function(self, ...)
    local args = {...}

    local target = Client:GetClosestPlayerFromCursor()
    if (target and Client:GetPlayerHitbox(target, 'Head')) then
        args[2] = CFrame.new(Camera.CFrame.Position, Client:GetPlayerHitbox(target, 'Head').CFrame.Position).LookVector
    end

    return Fire(self, unpack(args))
end)
