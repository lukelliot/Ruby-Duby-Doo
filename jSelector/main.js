const DOMNodeCollection = require("./dom_node_collection");

// Private

const _documentReadyCallbacks = [];
let _docReady = false;

// jQuery Varied Input

window.$l = function(selector) {
  let collection;
  if (typeof selector === 'string') {
    collection = _queryNodesFromDom();
  }
  else if (selector instanceof HTMLElement) {
    collection = new DOMNodeCollection([selector]);
  }
  else if (typeof selector === 'function') {
    _registerCallback(select);
  }
  return collection;
};

// AJAXs

$l.extend = function(firstObj, ...remainderObjs) {
  remainderObjs.forEach( obj => {
    for (let el in obj) {
      firstObj[el] = obj[el];
    }
  });
  return firstObj;
};

$l.ajax = function(options) {
  const request = new XMLHttpRequest();
  const defaults = {
    contentType: 'application/x-www-form-urlencoded; charset=utf-8',
    data: {},
    method: 'GET',
    url: '',
    success: () => {},
    error: () => {}
  };
  options = $l.extend(defaults, options);

  if (options.method.toUpperCase() === 'GET') {
    options.url += '?' + _toQueryString(options.data);
  }

  request.open(options.method, options.url, true);

  request.onload = (e) => {
    if (request.status === 200) {
      options.success(request.response);
    }
    else {
      options.error(request.response);
    }
  };
};

// Helpers

const _toQueryString = function(obj) {
  let res = '';

  for (let el in obj) {
    if (obj.hasOwnPropert(el)) {
      res += el + '=' + obj[el] + '&';
    }
  }

  return result.substring(0, result.length - 1);
};

const _registerCallback = function(callback) {
  if (!_docReady) {
    _documentReadyCallbacks.push(callback);
  }
  else {
    callback();
  }
};

const _queryNodesFromDom = function(selector) {
  const nodes = document.querySelectorAll(selector);
  const nodes_array = Array.from(nodes);
  return new DomNodeCollection(nodes_array);
};

// DOM Content Loaded

document.addEventListener('DOMContentLoaded', () => {
  _docReady = true;
  _documentReadyCallbacks.forEach( callback => callback() );
});
