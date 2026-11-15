// Alikuryer: read-only Supabase catalog, matching the inspected 15-table schema.
// This module never creates orders or uses privileged database credentials.
export function createAlikuryerCatalog(supabase) {
  if (!supabase) throw new Error("Supabase client kerak");
  const check = ({data,error}) => { if(error) throw error; return data ?? []; };
  return {
    async restaurants() {
      return check(await supabase.from("restaurants")
        .select("id,name,description,address_line,latitude,longitude,phone,is_active")
        .eq("is_active",true).order("name"));
    },
    async categories() {
      return check(await supabase.from("categories")
        .select("id,name,sort_order").order("sort_order"));
    },
    async menuItems(restaurantId) {
      if (!restaurantId) throw new Error("Restoran ID talab qilinadi");
      return check(await supabase.from("menu_items")
        .select("id,restaurant_id,category_id,name,description,price_uzs,image_path,is_available")
        .eq("restaurant_id",restaurantId).eq("is_available",true).order("name"));
    },
    async myOrders() {
      const {data:session,error:authError}=await supabase.auth.getUser();
      if(authError) throw authError;
      if(!session.user) throw new Error("Avval tizimga kiring");
      return check(await supabase.from("orders")
        .select("id,restaurant_id,delivery_address,status,subtotal_uzs,delivery_fee_uzs,total_uzs,created_at")
        .eq("customer_id",session.user.id).order("created_at",{ascending:false}));
    }
  };
}
