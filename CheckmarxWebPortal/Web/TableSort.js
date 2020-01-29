var sortField = "";
var sortOrder = "";
var showPage = 0;
var pageSize = 0;
var tableFilter = "";
var loadedSort = 0;

function MTVCreated( grid, args ) {
	var urlParams = new URLSearchParams( window.location.hash.substring(1) );	
	var MTV = grid.get_masterTableView();

	if ( urlParams.has( "showPage" ) ) showPage = parseInt( urlParams.get("showPage") );
	if ( urlParams.has( "pageSize" ) ) pageSize = parseInt( urlParams.get("pageSize") );

	if ( tableFilter == "" && urlParams.has( "filter" ) && urlParams.get("filter")!="" ) {
		tableFilter = urlParams.get("filter");
		var params = tableFilter.split( "|?" );
		setTimeout( function(){ MTV.showFilterItem(); MTV.filter( params[0], params[1], params[2]); }, 500 );

	} else if ( sortField == "" && urlParams.has( "sort" ) && loadedSort == 0 ) {
		var sort = urlParams.get("sort").replace( "/[^a-zA-Z]", "");
		var order = "ASC";
		if ( urlParams.has("order") ) { order = urlParams.get("order").replace("/[^a-zA-Z]/", "" ); }
	
		grid.get_masterTableView()._sortExpressions.clear();

		grid.get_masterTableView().sort( sort + " " + order );
		loadedSort = 1;
	} else if ( pageSize != 0 && pageSize != MTV.get_pageSize() ) {
		MTV.set_pageSize( pageSize );
	} else if ( showPage != MTV.get_currentPageIndex()+1 ) {
		if ( showPage > MTV.get_pageCount() ) showPage = MTV.get_pageCount();
		MTV.set_currentPageIndex( showPage );
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
	var urlParams = new URLSearchParams( window.location.hash.substring(1) );	
	
	var hash = "#";
	if ( sortField != "" ) {
		hash += "&sort=" + sortField;
	} else if ( urlParams.has("sort") ) {
		hash += "&sort=" + urlParams.get("sort");
	}

	if ( sortOrder != 0 ) {
		hash += "&order=" + sortOrder;
	} else if ( urlParams.has("order") ) {
		hash += "&order=" + urlParams.get("order");
	}

	if ( pageSize != 0 ) {
		hash += "&pageSize=" + pageSize;
	} else if ( urlParams.has("pageSize") ) {
		hash += "&pageSize=" + urlParams.get("pageSize");
	}

	if ( showPage != 0 ) {
		hash += "&showPage=" + showPage;
	} else if ( urlParams.has("showPage") ) {
		hash += "&showPage=" + urlParams.get("showPage");
	}

	if ( tableFilter != 0 ) {
		hash += "&filter=" + tableFilter;
	} else if ( urlParams.has("filter") ) {
		hash += "&filter=" + urlParams.get("filter");
	}

	window.location.hash = hash;
}

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