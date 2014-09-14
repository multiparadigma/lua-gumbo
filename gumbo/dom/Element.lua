local util = require "gumbo.dom.util"

local Element = util.merge("Node", "ChildNode", {
    type = "element",
    nodeType = 1,
    attributes = {}
})

local getters = {}

-- TODO: This attribute is not readonly -- also implement a setter
function getters:id()
    local id_attr = self.attributes.id
    return id_attr and id_attr.value
end

-- TODO: This attribute is not readonly -- also implement a setter
function getters:className()
    local class_attr = self.attributes.class
    return class_attr and class_attr.value
end

-- TODO: implement all cases from http://www.w3.org/TR/dom/#dom-element-tagname
function getters:tagName()
    if self.namespace then
        return self.localName
    else
        return self.localName:upper()
    end
end

getters.nodeName = getters.tagName

function Element:__index(k)
    if type(k) == "number" then
        return self.childNodes[k]
    end
    local field = Element[k]
    if field then
        return field
    else
        local getter = getters[k]
        if getter then
            return getter(self)
        end
    end
end

function Element:__len()
    return #self.childNodes
end

local function attr_next(attrs, i)
    local j = i + 1
    local a = attrs[j]
    if a then
        return j, a.name, a.value, a.prefix, a.line, a.column, a.offset
    end
end

function Element:attr_iter()
    return attr_next, self.attributes, 0
end

function Element:hasAttribute(name)
    if type(name) == "string" then
        -- If the context object is in the HTML namespace and its node document
        -- is an HTML document, let name be converted to ASCII lowercase.
        if self.namespace == nil --[[and self.ownerDocument.ISHTMLDOC]] then
            name = name:lower()
        end
        -- Return true if the context object has an attribute whose name is
        -- name, and false otherwise.
        return self.attributes[name] and true or false
    end
    return false
end

function Element:getAttribute(name)
    if type(name) == "string" then
        -- If the context object is in the HTML namespace and its node document
        -- is an HTML document, let name be converted to ASCII lowercase.
        if self.namespace == nil --[[and self.ownerDocument.ISHTMLDOC]] then
            name = name:lower()
        end
        -- Return the value of the first attribute in the context object's
        -- attribute list whose name is name, and null otherwise.
        local attr = self.attributes[name]
        if attr then
            return attr.value
        end
    end
end

return Element