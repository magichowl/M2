--done: list, map
--not done: suchthat

--- From OpenMath ---
OMSEvaluators#"list1" = new MutableHashTable;
OMSEvaluators#"list1"#"list" = (args, attrs) -> apply(args, fromOpenMath)
OMSEvaluators#"list1"#"map" = (args, attrs) -> (
	f := fromOpenMath(args#0);
	l := fromOpenMath(args#1);
	apply(l, f)
)


