function DOMNodeCollection(HTMLElements) {
  this.elements = HTMLElements;
}

DOMNodeCollection.prototype.html = function(string) {
  if (typeof string === "string") {
    this.elements.forEach( el => {
      el.innerHTML = string;
    });
  }
  else {
    return this.elements[0].innerHTML;
  }
};

DOMNodeCollection.prototype.empty = function () {
  this.html("");
};

DOMNodeCollection.prototype.append = function(collection) {
  if (typeof collection === 'string'){
    collection = new DOMNodeCollection(document.querySelectorAll(collection));
  }
  else if (typeof collection === HTMLElement) {
    collection = new DOMNodeCollection([collection]);
  }

  for (let outer = 0; outer < collection.elements.length; outer++) {
    for (let inner = 0; inner < this.elements.length; inner++) {
      this.elements[inner].innerHTML += collection.elements[outer].outerHTML;
    }
  }
};

DOMNodeCollection.prototype.attr = function(attribute, value) {
  if (value === undefined) {
    return this.elements[0].getAttribute(attribute);
  } else {
    this.elements.forEach( el => {
      el.setAttribute(attribute, value);
    });
  }
};

DOMNodeCollection.prototype.addClass = function(className) {
  let prevClassName = this.attr("class");
  if (prevClassName) {
    className = prevClassName + ` ${className}`;
  }

  this.attr("class", className);
};

DOMNodeCollection.prototype.removeClass = function(className) {
  let existingClassNames = this.attr("class");

  if (existingClassNames) {
    splitClassNames = existingClassNames.split(" ");
    indexToDelete = splitClassNames.indexOf(className);

    if (indexToDelete >= 0) {
      splitClassNames.splice(indexToDelete, 1);
      joinedClassNames = splitClassNames.join(" ");
      this.attr("class", joinedClassNames);
    }
  }
};

DOMNodeCollection.prototype.children = function () {
  let allChildren = [];

  this.elements.forEach( el => {
    for (let i = 0; i < el.children.length; i++) {
      allChildren.push(el.children[i]);
    }
  });

  return new DOMNodeCollection(allChildren);
};

DOMNodeCollection.prototype.parent = function () {
  let allParents = [];

  this.elements.forEach( el => {
    if (!allParents.includes(el.parentNode)){
      allParents.push(el.parentNode);
    }
  });

  return new DOMNodeCollection(allParents);
};

DOMNodeCollection.prototype.find = function(selector) {
  const allSelectedDescendents = [];

  this.elements.forEach( el => {
    let selectedDescendents = el.querySelectorAll(selector);

    for (let i = 0; i < selectedDescendents.length; i++) {
      allSelectedDescendents.push(selectedDescendents[i]);
    }
  });

  return new DOMNodeCollection(allSelectedDescendents);
};

DOMNodeCollection.prototype.remove = function () {
  this.elements.forEach( el => {
    el.outerHTML = "";
  });

  this.elements = [];
};


DOMNodeCollection.prototype.on = function(type, callback) {
  this.elements.forEach( el => {
    el.addEventListener(type, callback);
  });
};

DOMNodeCollection.prototype.off = function(type, callback) {
  this.elements.forEach( el => {
    el.removeEventListener(type, callback);
  });
};




module.exports = DOMNodeCollection;
