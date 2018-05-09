drop table if exists di3metadata.measures;
create table di3metadata.measures as 
select * from di3metadata.nci_thesaurus where c_fullname like  '%C20189%' and
c_basecode in ('NCIt:C20189', 'NCIt:C25285', 'NCIt:C96684', 'NCIt:C25447', 'NCIt:C25335');

update di3metadata.measures set c_fullname = substr(c_fullname, 6);
update di3metadata.measures set c_dimcode = substr(c_dimcode, 6);
update di3metadata.measures set c_path = substr(c_path, 6);

update di3metadata.measures set c_visualattributes = 'LA' where c_basecode = 'NCIt:C25335';

update di3metadata.measures set c_metadataxml = 
'<?xml version="1.0"?>
            <ValueMetadata>
            <Version>3.02</Version>
            <CreationDateTime>11/07/2017 14:53:45</CreationDateTime>
            <TestID>Volume</TestID>
             <TestName>Volume</TestName>
             <DataType>PosFloat</DataType>
            <Loinc></Loinc>
            <Flagstouse></Flagstouse>
            <Oktousevalues>Y</Oktousevalues>
<LowofLowValue>0</LowofLowValue><HighofLowValue>0</HighofLowValue>
<LowofHighValue>400</LowofHighValue>
<HighofHighValue>400</HighofHighValue>
<EnumValues></EnumValues>
<CommentsDeterminingExclusion>
<Com></Com>
</CommentsDeterminingExclusion>
<UnitValues>
<NormalUnits>cc</NormalUnits>
<EqualUnits>CC</EqualUnits>
</UnitValues><Analysis><Enums /><Counts /><New /></Analysis>
</ValueMetadata>
' where c_basecode = 'NCIt:C25335';


update di3metadata.measures set c_metadataxml = 
'<?xml version="1.0"?>
            <ValueMetadata>
            <Version>3.02</Version>
            <CreationDateTime>11/07/2017 14:53:45</CreationDateTime>
            <TestID>Longest Diameter</TestID>
             <TestName>Longest Diameter</TestName>
             <DataType>PosFloat</DataType>
            <Loinc></Loinc>
            <Flagstouse></Flagstouse>
            <Oktousevalues>Y</Oktousevalues>
<LowofLowValue>0</LowofLowValue><HighofLowValue>0</HighofLowValue>
<LowofHighValue>250</LowofHighValue>
<HighofHighValue>250</HighofHighValue>
<EnumValues></EnumValues>
<CommentsDeterminingExclusion>
<Com></Com>
</CommentsDeterminingExclusion>
<UnitValues>
<NormalUnits>mm</NormalUnits>
<EqualUnits>MM</EqualUnits>
<ConvertingUnits>
 <Units>cm</Units>
 <MultiplyingFactor>10</MultiplyingFactor>
</ConvertingUnits> 
</UnitValues><Analysis><Enums /><Counts /><New /></Analysis>
</ValueMetadata>
' where c_basecode = 'NCIt:C96684' ;
