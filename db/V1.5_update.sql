##Polymorphic tabs##
ALTER TABLE tabs DROP FOREIGN KEY tabs_ibfk_1;

ALTER TABLE `tabs`
  DROP `guide_id`,
  DROP `page_id`;

ALTER TABLE `tabs` ADD INDEX ( `tabable_id` , `tabable_type` ) ;

#new quiz type#
ALTER TABLE `answers` ADD `feedback` TEXT NULL ;