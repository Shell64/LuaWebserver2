local Application = Class.New("Application")

Application.GetSet("GET", "function")
Application.GetSet("POST", "function")
Application.GetSet("PUT", "function")
Application.GetSet("HEAD", "function")
Application.GetSet("DELETE", "function")
Application.GetSet("OPTIONS", "function")

function Application.Include(Path)
end

return Application