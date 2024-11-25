satlantis_collect_email = {}

local storage = core.get_mod_storage()

local register_url = "https://satlantis.net/register"

local get_email_form_name = "satlantis_collect_email:get_email_form"
local confirmation_form_name = "satlantis_collect_email:confirmation_form"

function satlantis_collect_email.get_email_formspec(error_msg)
  local instructions = "Enter your email to migrate your Minetest account:"

  local formspec = {
    "formspec_version[4]",
    "size[6,6]",

    "label[0.375,0.5;", core.formspec_escape(instructions), "]",
    "field[0.375,1.5;5.25,0.8;email1;E-mail:;]",
    "field[0.375,3;5.25,0.8;email2;Enter your e-mail again:;]",

    "button[1.5,4.5;3,0.8;save;Save]"
  }

  local formspec_error = {
    "formspec_version[4]",
    "size[6,6.5]",

    "label[0.375,0.5;", core.formspec_escape(error_msg), "]",
    "label[0.375,1.5;", core.formspec_escape(instructions), "]",
    "field[0.375,2;5.25,0.8;email1;E-mail:;]",
    "field[0.375,3.5;5.25,0.8;email2;Enter your e-mail again:;]",

    "button_exit[1.5,5;3,0.8;save;Save]"
  }

  if error_msg then
    return table.concat(formspec_error, "")
  else
    return table.concat(formspec, "")
  end
end

function satlantis_collect_email.get_confirmation_formspec()
  local instructions = "You must now register using the same e-mail at our website.\nClick the 'Register' button below to be redirected."

  local formspec = {
    "formspec_version[4]",
    "size[7.650,3]",

    "label[0.375,0.5;", core.formspec_escape(instructions), "]",
    "button_exit[0.675,1.8;2.875,0.8;cancel;Cancel]",
    "button_url[4.1,1.8;2.875,0.8;register;Register;", core.formspec_escape(register_url), "]"
  }
  return table.concat(formspec, "")
end

function satlantis_collect_email.show_collect_email_form(p_name, error_msg)
  core.show_formspec(p_name, get_email_form_name, satlantis_collect_email.get_email_formspec(error_msg))
end

function satlantis_collect_email.show_confirmation_form(p_name)
  core.show_formspec(p_name, confirmation_form_name, satlantis_collect_email.get_confirmation_formspec())
end

function satlantis_collect_email.get_player_email(p_name)
  return storage:get_string(p_name)
end

function satlantis_collect_email.set_player_email(p_name, email)
  storage:set_string(email, p_name)
  storage:set_string(p_name, email)
end

function satlantis_collect_email.is_taken_by_another_user(p_name, email)
  local usr = storage:get_string(email)
  return usr ~= "" and usr ~= p_name
end

local function validate_email(str)
  -- Based on the original code from https://ohdoylerules.com/snippets/validate-email-with-lua/
  if str == nil or str:len() == 0 then return nil end
  if (type(str) ~= 'string') then
    return false
  end
  local lastAt = str:find("[^%@]+$")
  local localPart = str:sub(1, (lastAt - 2)) -- Returns the substring before '@' symbol
  local domainPart = str:sub(lastAt, #str) -- Returns the substring after '@' symbol
  -- we werent able to split the email properly
  if localPart == nil then
    return false
  end

  if domainPart == nil or not domainPart:find("%.") then
    return false
  end
  if string.sub(domainPart, 1, 1) == "." then
    return false
  end
  -- local part is maxed at 64 characters
  if #localPart > 64 then
    return false
  end
  -- domains are maxed at 253 characters
  if #domainPart > 253 then
    return false
  end
  -- somthing is wrong
  if lastAt >= 65 then
    return false
  end
  -- quotes are only allowed at the beginning of a the local name
  local quotes = localPart:find("[\"]")
  if type(quotes) == 'number' and quotes > 1 then
    return false
  end
  -- no @ symbols allowed outside quotes
  if localPart:find("%@+") and quotes == nil then
    return false
  end
  -- no dot found in domain name
  if not domainPart:find("%.") then
    return false
  end
  -- only 1 period in succession allowed
  if domainPart:find("%.%.") then
    return false
  end
  if localPart:find("%.%.") then
    return false
  end
  -- just a general match
  if not str:match('[%w]*[%p]*%@+[%w]*[%.]?[%w]*') then
    return false
  end
  -- all our tests passed, so we are ok
  return true
end

function satlantis_collect_email.handle_email_form(player, fields)
  local p_name = player:get_player_name()
  local email = fields.email1

  if not validate_email(email) then
    satlantis_collect_email.show_collect_email_form(p_name, "Invalid email address.")
    return true
  end

  if email ~= fields.email2 then
    satlantis_collect_email.show_collect_email_form(p_name, "Please check if both fields match.")
    return true
  end

  if satlantis_collect_email.is_taken_by_another_user(p_name, email) then
    satlantis_collect_email.show_collect_email_form(p_name, "This e-mail address is already in use.")
    return true
  end

  satlantis_collect_email.set_player_email(p_name, fields.email1)
  satlantis_collect_email.show_confirmation_form(p_name)
  return true
end

function satlantis_collect_email.handle_confirmation_form(player, fields)
  return true
end

core.register_on_joinplayer(
  function(player)
    local p_name = player:get_player_name()
    local email = satlantis_collect_email.get_player_email(p_name)

    if email == "" then
      core.after(1, function()
        satlantis_collect_email.show_collect_email_form(p_name)
      end)
    end
  end
)

core.register_on_player_receive_fields(function(player, formname, fields)
  if formname == get_email_form_name then
    return satlantis_collect_email.handle_email_form(player, fields)
  elseif formname == confirmation_form_name then
    return satlantis_collect_email.handle_confirmation_form(player, fields)
  end
  return false
end)