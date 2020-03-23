insert into di3crcdata.qt_query_result_type(result_type_id, name, description, display_type_id, visual_attribute_type_id)
values (10, 'DATASET_COUNT_XML', 'Data set breakdown', 'CATNUM', 'LA'
);

insert into di3crcdata.qt_breakdown_path(name, value, create_date, update_date, user_id)
values('DATASET_COUNT_XML', $$\\DI3_DATASET\Data Set\$$, current_timestamp, NULL, 'hickmanhb');

/* Also have to change the CRCApplicationContext.xml to add in the new count type */


insert into di3crcdata.qt_query_result_type(result_type_id, name, description, display_type_id, visual_attribute_type_id)
values (12, 'ANATOMIC_SITE_COUNT_XML', 'Anatomic site breakdown', 'CATNUM', 'LA'
);

insert into di3crcdata.qt_breakdown_path(name, value, create_date, update_date, user_id)
values('ANATOMIC_SITE_COUNT_XML', $$\\DI3_SITE\Anatomic Site\$$, current_timestamp, NULL, 'hickmanhb');

insert into di3crcdata.qt_query_result_type(result_type_id, name, description, display_type_id, visual_attribute_type_id)
values (13, 'COURSE_OF_DISEASE_COUNT_XML', 'Clinical course of disease breakdown', 'CATNUM', 'LA'
);

insert into di3crcdata.qt_breakdown_path(name, value, create_date, update_date, user_id)
values('COURSE_OF_DISEASE_COUNT_XML', $$\\DI3_CLINICAL_COURSE_OF_DISEASE\Clinical Course of Disease\$$, current_timestamp, NULL, 'hickmanhb');
