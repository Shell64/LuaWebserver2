local Application = Class.New("Application")

Application.GetSet("GET", "function")
Application.GetSet("POST", "function")
Application.GetSet("PUT", "function")

function Application.Include(Path)
end

return Application