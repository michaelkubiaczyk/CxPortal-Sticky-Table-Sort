var storedParamName = "fs_params";

var tableParams = ["filter", "sort", "order", "pageSize", "showPage" ];
var defaultState = new URLSearchParams( "showPage=0&pageSize=0&filter=" );
var currentState = new URLSearchParams( "showPage=0&pageSize=0&filter=" );
var currentFilters = new Map();
var targetFilters = new Map();
var targetState = new URLSearchParams("");
var targetReached = 1;
var MTV;
// Telerik.Web.UI.Grid.Sort($find('ctl00_cpmain_ProjectsGrid_ctl00'), 'LastScanned'); return false;__doPostBack('ctl00$cpmain$ProjectsGrid$ctl00$ctl02$ctl02$ctl28','')

var columnSortRegex = /Telerik\.Web\.UI\.Grid\.Sort\(.+\),\s+'(\w+)'\)\;/ ;


function MTVCreated( grid, args ) {

	MTV = grid.get_masterTableView();
	if ( !MTV ) {
		setTimeout( function() { MTVCreated( grid, args ); }, 100 );
	}

	currentState.set( "pageSize", MTV.get_pageSize() );
	currentState.set( "showPage", MTV.get_currentPageIndex()+1 );

	if ( !currentState.has( "sort" ) || currentState.get( "sort" ) == "" ) {
		//alert( "Checking sorts?" );
		var sorts = document.getElementsByClassName( "rgHeader rgSorted" );
		if ( sorts.length > 0 ) {
			for ( var i = 0; i < sorts[0].childNodes.length; i++ ) {
				var n = sorts[0].childNodes[i];
				if ( n.nodeName == 'INPUT' ) {
					//alert( n.title );
					if ( n.title.match(/Sorted desc/i) ) 
						currentState.set( "order", "DESC" );
					else 
						currentState.set( "order", "ASC" );
					
					//alert( "Checking: " + String(n.onclick) );
					var col = columnSortRegex.exec(String(n.onclick));
					if ( col !== null ) {
						currentState.set( "sort", col[1] );
						//alert( "Currently sorting: " + col[1] );
					}
					break;
				}
			}
		}
	}
	
//	alert( "Current state: " + currentState.toString() + "\nTarget: " + targetState.toString() );

	var diffs = 0;
	for ( var i = 0; i < tableParams.length; i++ ) {
		var p = tableParams[i];
		if ( targetState.has( p ) && targetState.get( p ) != currentState.get( p ) ) {
			diffs = 1;
			updateTable( p, targetState.get( p ) );
			break;
		}	
	}
	
	if ( diffs == 0 && targetReached == 0 ) {
		targetReached = 1;
		if ( typeof(Storage) !== "undefined" && sessionStorage.getItem( storedParamName ) != null ) {
			sessionStorage.removeItem( storedParamName );
		}
	}
	

	
}

function updateTable( param, value ) {
	//alert( "Need to set param " + param + " to " + value );
	switch (param) {
		case "filter":
			//alert("Updating Filters:\nFrom: " + getFilterString( currentFilters ) + "\nTo: " + getFilterString( targetFilters ) );
			for ( var [key, filter] of targetFilters ) {
				//alert( "Want to set filter " + key + " to " + filter + "\nCurrently: " + currentFilters.get( key ) );
				
				if ( !currentFilters.has( key ) || currentFilters.get(key) !== filter ) {					
					var parameters = filter.split( "|?" );
					setTimeout( function(){ MTV.showFilterItem(); MTV.filter( parameters[0], parameters[1], parameters[2]); }, 500 );
					break;
				}
			}
			break;
		case "sort":
			var sort = value.replace( "/[^a-zA-Z]", "");
			var order = currentState.get( "order" );
			if ( targetState.has("order") ) { 
				order = targetState.get("order"); 
				if ( order != "ASC" && order != "DESC" ) {
					order = "ASC";
				}
			}

			MTV._sortExpressions.clear();

			if ( sort == "" ) {
				//alert ( "trying to sort with empty sort: " + sort + ", " + order );
				sort = currentState.get( "sort" );
				order = "";
			}
			setTimeout( function(){ MTV.sort( sort + " " + order ); }, 500 );
			break;
		case "order":
			var order = value.replace( "/[^a-zA-Z]", "");
			var sort = currentState.get( "sort" );
			if ( targetState.has("sort") ) { 
				sort = targetState.get("sort").replace( "/[^a-zA-Z]", ""); 
			}

			MTV._sortExpressions.clear();

			setTimeout( function(){ MTV.sort( sort + " " + order ); }, 500 );
			break;
		case "page":
        case "showPage":
			if ( value > MTV.get_pageCount() ) value = MTV.get_pageCount();
			MTV.set_currentPageIndex( value );			
			break;
		case "pageSize":
			MTV.set_pageSize( parseInt(value) );
            break;
	}
}

function GridCommand( grid, args ) {
	//alert( "Command: " + args.get_commandName() + ", params: " + args.get_commandArgument() );
	if ( args.get_commandName() == "Sort" ) {
		var sort = args.get_commandArgument();
		var res = sort.split(" ");
	
		var sortField = currentState.get( "sort" ), sortOrder = currentState.get( "order" );
	
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
		currentState.set( "sort", sortField );
		currentState.set( "order", sortOrder );
	} else if ( args.get_commandName() == "PageSize" ) {
		currentState.set( "pageSize", args.get_commandArgument() );
	} else if ( args.get_commandName() == "Page" ) {
		currentState.set( "showPage", args.get_commandArgument() );
	} else if ( args.get_commandName() == "Filter" ) {
		var filter = args.get_commandArgument().split( "|?", 3 );
		//alert( "Filtering: " + filter[0] + ", " + filter[1] + ", " + filter[2] );
		if ( filter[1] == "" ) { // want to unfilter this column
			//currentState.delete( "filter" );
			currentFilters.delete( filter[0] );
		} else {
			//currentState.set( "filter", args.get_commandArgument() );
			currentFilters.set( filter[0], args.get_commandArgument() );			
			currentState.set( "filter", getFilterString( currentFilters ) );
		}
	}

	window.location.hash = "#" + currentState.toString();
	if ( targetReached == 1 ) targetState = currentState;
}

function getFilterString( filterMap ) {
	var filterString = "";
	filterMap.forEach( function(value){
		if ( filterString == "" ) 
			filterString = value;
		else
			filterString += "||" + value;
	});
	return filterString;
}

function showProps( obj ) {
	var str = "";
	for ( var k in obj ) {
		str += k + "=" + obj[k] + ";\n";
	}
	return str;
}
function showPropsVS( obj, search ) {
	var str = "";
	for ( var k in obj ) {
		if ( String(obj[k]).includes( search ) ) {
			str += k + "=" + obj[k] + ";\n";
		}
	}
	return str;
}

function sanitize( str ) {
	return str.replace(/[^a-zA-Z0-9\-_?\&|=]/g, "");
}

function onPageLoad() { 
	// If the page is loaded with a hash present, save that hash
	// If the page loads without a hash present, but there's one saved, load the saved one
//	alert( "OnLoad" );
	if (window.location.hash == "" && typeof(Storage) !== "undefined" && sessionStorage.getItem( storedParamName ) != null ) {
		targetHash = sanitize( sessionStorage.getItem( storedParamName ) );
//		alert( "Loaded hash: " + targetHash + "\nSanitized: " + sanitize(targetHash) );
		targetState = new URLSearchParams( targetHash );
		targetReached = 0;
		sessionStorage.removeItem( storedParamName );
//		alert( "Loaded stored URL: " + targetHash );
	}
	
	if (window.location.hash != "" ) {
		var dec = decodeURIComponent(window.location.hash.substring(1));
		targetHash = sanitize(dec);
		//alert( "Window hash: " + window.location.hash.substring(1) + "\ndecoded: " + dec + "\nsanitied: " + targetHash	) 
		targetState = new URLSearchParams( targetHash );
		
		
		//alert( "Target filters from " + targetState.get("filter") + "\n" + getFilterString( targetFilters ) );		
		
		sessionStorage.setItem( storedParamName, targetHash );
		targetReached = 0;
	}
	
	if ( targetState.has( "filter" ) ) {
		var filters = targetState.get( "filter" ).split( "||" );
		filters.forEach( function(value) {
			var filter = value.split( "|?", 3 );
			targetFilters.set( filter[0], value );
		});
	}
}

onPageLoad();