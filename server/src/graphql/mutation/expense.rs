//! Input objects needed to modify convention expense
use chrono::{DateTime,FixedOffset};
use database::Money;

#[derive(Clone, GraphQLInputObject)]
#[graphql(description="Information required to create a convention expense")]
pub struct ExpenseAdd {
    pub con_id: i32,
    pub price: Money,
    pub category: String,
    pub description: String,
    pub time: DateTime<FixedOffset>,
}

#[derive(Clone, GraphQLInputObject)]
#[graphql(description="Information required to modify a convention expense")]
pub struct ExpenseMod {
    pub expense_id: i32,
    pub price: Option<Money>,
    pub category: Option<String>,
    pub description: Option<String>,
}

#[derive(Clone, GraphQLInputObject)]
#[graphql(description="Information required to delete a convention expense")]
pub struct ExpenseDel {
    pub expense_id: i32,
}
