var sortField = "";
var sortOrder = 0;
var showPage = 0;
var pageSize = 0;
var tableFilter = "";
var loadedSort = 0;
var originalHash = "";

function MTVCreated( grid, args ) {
	var urlParams = getParams();	
	//alert( "Created: " + urlParams );
	var MTV = grid.get_masterTableView();

	if ( urlParams.has( "showPage" ) ) showPage = parseInt( urlParams.get("showPage") );
	if ( urlParams.has( "pageSize" ) ) pageSize = parseInt( urlParams.get("pageSize") );

	if ( tableFilter == "" && urlParams.has( "filter" ) && urlParams.get("filter")!="" ) {
		tableFilter = urlParams.get("filter");
		var params = tableFilter.split( "|?" );
		setTimeout( function(){ MTV.showFilterItem(); MTV.filter( params[0], params[1], params[2]); }, 500 );

	} else if ( sortField == "" && urlParams.has( "sort" ) && loadedSort == 0 ) {
		var sort = urlParams.get("sort").replace( "/[^a-zA-Z]", "");
		var order = "none";
		if ( urlParams.has("order") ) { order = urlParams.get("order").replace("/[^a-zA-Z]/", "" ); }

		grid.get_masterTableView()._sortExpressions.clear();

		setTimeout( function(){ grid.get_masterTableView().sort( sort + " " + order ); }, 500 );
		loadedSort = 1;
	} else if ( pageSize != 0 && pageSize != MTV.get_pageSize() ) {
		MTV.set_pageSize( pageSize );
	} else if ( showPage > 0 && showPage != MTV.get_currentPageIndex()+1 ) {
		if ( showPage > MTV.get_pageCount() ) showPage = MTV.get_pageCount();
		MTV.set_currentPageIndex( showPage );
	}
}

function getParams() {
	if (window.location.hash) {
		return new URLSearchParams( sanitize( decodeURI( window.location.hash.substring(1)) ) );
	}
	if (typeof(Storage) !== "undefined" && document.referrer.match("authCallback")) {
		return new URLSearchParams( sanitize(localStorage.getItem( "fs_params" )) );
	}
	return new URLSearchParams("");
}
function setParams( params ) {
	window.location.hash = "#" + params;
	if (typeof(Storage) !== "undefined") {
		localStorage.setItem( "fs_params", params );
	}
}

function GridCommand( grid, args ) {
	if ( args.get_commandName() == "Sort" ) {
		var sort = args.get_commandArgument();
		var res = sort.split(" ");
	
		if ( sortField == res[0] ) {
			if ( sortOrder == "ASC" ) {
				sortOrder = "DESC";
			} else if ( sortOrder == "DESC" ) {
				sortOrder = "";
				sortField = "";
			} else { 
				sortOrder = "ASC";
			}
		} else { 
			sortField = res[0];
			if ( res[1] == "DESC" ) {
				sortOrder = "DESC";
			} else {
				sortOrder = "ASC";
			}
		}
	} else if ( args.get_commandName() == "PageSize" ) {
		pageSize = args.get_commandArgument();
	} else if ( args.get_commandName() == "Page" ) {
		showPage = args.get_commandArgument();
	} else if ( args.get_commandName() == "Filter" ) {
		tableFilter = args.get_commandArgument();
	}

	updateHash();
}

function updateHash() {
	var originalParams = new URLSearchParams( sanitize( originalHash ) );
	
	var hash = ""; 
	if ( sortField != "" ) {
		hash += "&sort=" + sortField;
	} else if ( originalParams.has("sort") ) {
		hash += "&sort=" + originalParams.get("sort");
	}

	if ( sortOrder != 0 ) {
		hash += "&order=" + sortOrder;
	} else if ( originalParams.has("order") ) {
		hash += "&order=" + originalParams.get("order");
	}


	if ( pageSize != 0 ) {
		hash += "&pageSize=" + pageSize;
	} else if ( originalParams.has("pageSize") ) {
		hash += "&pageSize=" + originalParams.get("pageSize");
	}

	if ( showPage != 0 ) {
		hash += "&showPage=" + showPage;
	} else if ( originalParams.has("showPage") ) {
		hash += "&showPage=" + originalParams.get("showPage");
	}

	if ( tableFilter != 0 ) {
		hash += "&filter=" + tableFilter;
	} else if ( originalParams.has("filter") ) {
		hash += "&filter=" + originalParams.get("filter");
	}

	setParams(hash);
}

/* // helper for debugging
function showProps( obj ) {
	var str = "";
	for ( var k in obj ) {
		str += k + "; ";
	}
	return str;
}
function showPropsS( obj, search ) {
	var str = "";
	for ( var k in obj ) {
		if ( k.toString().indexOf( search ) >= 0 ) str += k + "; ";
	}
	return str;
}

*/

function sanitize( str ) {
	return str.replace(/[^a-zA-Z0-9\-_?&|=]/g, "");
}

function onPageLoad() {
	if (window.location.hash && typeof(Storage) !== "undefined" && localStorage.getItem( "fs_param" ) != window.location.hash.substring(1) ) {
		localStorage.setItem( "fs_params", decodeURI( window.location.hash.substring(1) ) );
		originalHash = window.location.hash;
	}
}

onPageLoad();