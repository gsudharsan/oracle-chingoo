<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>
<%! 
	final int MAX_CACHE_LIST = 500;
	final int MAX_DISPLAY_LIST = 50;

	public String getNumRows (String numRows) {
		if (numRows==null) numRows = "";
		else {
			int n = Integer.parseInt(numRows);
			if (n < 1000) {
				numRows = numRows;
			} else if (n < 1000000) {
				numRows = Math.round(n /1000) + "K";
			} else {
				numRows = (Math.round(n /100000) / 10.0 )+ "M";
			}
		}
		return numRows;
	}

%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String term = request.getParameter("term");
	String filter = term.trim();
	String xterm = (String) session.getAttribute("xterm-table");
	ArrayList<String> xlist = (ArrayList<String>) session.getAttribute("xlist-table");

	String qry = "SELECT object_name FROM user_objects where object_type in ('TABLE') " +
		" union all " +
		" SELECT synonym_name FROM USER_SYNONYMS A " +
		" where exists (select 1 from all_tables where owner=A.table_owner and table_name=A.table_name) " +
		" order by 1";
	if (cn.getTargetSchema() != null) {
		qry = "SELECT object_name FROM all_objects where owner='" + cn.getTargetSchema() + "' and object_type in ('TABLE') " +
				" union all " +
				" SELECT synonym_name FROM ALL_SYNONYMS A " +
				" where owner='" + cn.getTargetSchema() + "' and exists (select 1 from all_tables where owner=A.table_owner and table_name=A.table_name) " +
				" order by 1";
	}
	
	
//	String qry = "SELECT TABLE_NAME, NUM_ROWS FROM USER_TABLES ORDER BY 1"; 	
	List<String[]> list = cn.query(qry, true);
	
	int totalCnt = list.size();
	if (filter !=null) filter = filter.toUpperCase();
	
	List<String> res1 = new ArrayList<String>();
	if (xlist != null && term.startsWith(xterm) && xlist.size() < MAX_CACHE_LIST) {
		int cnt = 0;
		for (int i=0; i<xlist.size();i++) {
			if (xlist.get(i).contains(filter)) { 
				res1.add(xlist.get(i));
				cnt ++;
			}
			if (cnt >= MAX_CACHE_LIST) break; 
		}	
	} else {
		int cnt = 0;
		for (int i=0; i<list.size();i++) {
			if (list.get(i)[1].startsWith(filter)) { 
				res1.add(list.get(i)[1]);
				cnt ++;
				if (cnt >= MAX_CACHE_LIST) break; 
			} 
		}

		if (cnt < MAX_CACHE_LIST) {
			for (int i=0; i<list.size();i++) {
				if (!list.get(i)[1].startsWith(filter) && list.get(i)[1].contains(filter)) {
					res1.add(list.get(i)[1]);
					cnt ++;
				}
				if (cnt >= MAX_CACHE_LIST) break; 
			}
		}
	}
	session.setAttribute("xterm-table", term);
	session.setAttribute("xlist-table", res1);
%>

[
<%	
	for (int i=0; i<res1.size() && i < MAX_DISPLAY_LIST;i++) {
%>
<%=(i>0?",":"")%>{"value": "<%=res1.get(i)%>", "label": "<%=res1.get(i)%>", "desc": "<%= cn.getTableRowCount(res1.get(i).toUpperCase()) %>"} 
<% 
	} 
%>
]
