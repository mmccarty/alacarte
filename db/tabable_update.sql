UPDATE tabs SET tabable_id=guide_id,tabable_type='Guide' WHERE guide_id > 0;
UPDATE tabs SET tabable_id=page_id,tabable_type='Page' WHERE page_id > 0;