update evi_arb_case eac
   set eac.store_channel =
       (select edm.chnl_source
          from evi_data_main edm
         where eac.cont_no = edm.deal_id)
 where eac.id = (select eac.id from evi_data_main edm where eac.cont_no = edm.deal_id);

merge into evi_arb_case eac
using evi_data_main edm
on (eac.cont_no = edm.deal_id)
when matched then
  update set eac.store_channel = edm.chnl_source;

update evi_arb_case c
   set c.user_address =
       (select u.user_addr
          from evi_data_main m, evi_data_user u
         where m.partner_user_id = u.partner_user_id
           and c.cont_no = m.deal_id
           and c.partner_id = m.partner_id
           and c.product_id = m.product_id
           and c.savepoint_id = m.savepoint_id)
 where c.id = (select c.id
                 from evi_data_main m, evi_data_user u
                where m.partner_user_id = u.partner_user_id
                  and c.cont_no = m.deal_id
                  and c.partner_id = m.partner_id
                  and c.product_id = m.product_id
                  and c.savepoint_id = m.savepoint_id);

merge into evi_arb_case c
using (select m.deal_id,
              m.partner_id,
              m.product_id,
              m.savepoint_id,
              u.user_addr
         from evi_data_main m, evi_data_user u
        where m.partner_user_id = u.partner_user_id) t
on (c.cont_no = t.deal_id and c.partner_id = t.partner_id and c.product_id = t.product_id and c.savepoint_id = t.savepoint_id)
when matched then
  update set c.user_address = t.user_addr;

update evi_data_main t
   set t.chain_status = 1
 where exists (select 1
          from evi_data_chain c
         where t.id = c.chain_id
           and c.chain_type = 1
           and c.chain_status = 1);

merge into evi_data_main t
using evi_data_chain c
on (t.id = c.chain_id and c.chain_type = 1 and c.chain_status = 1)
when matched then
  update set t.chain_status = 1;
