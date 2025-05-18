# Kicksstart: Active Record Associations, Validations, and Callbacks

## Active Record Models

### Create the migration, the table and the model for Account

Creamos la migración para crear la tabla accounts

```sh
bundle exec rake db:create_migration NAME=create_accounts
```

Editamos la migración para crear la tabla accounts

```ruby
class CreateAccount < ActiveRecord::Migration[8.0]
  def change

    create_table :accounts do |t|
      t.references :user, foreign_key: true
      t.integer :balance
      t.timestamps
    end
  end
end
```

Creamos el modelo

```ruby
class Account < ActiveRecord::Base
end
```

TODO: Crear el modelo para la tabla transactions. Los mismos pasos que antes

## Step 3: Associations

Active Record associations allow you to define relationships between models. Associations are implemented as special macro style calls that make it easy to tell Rails how your models relate to each other, which helps you manage your data more effectively, and makes common operations simpler and easier to read.

### Account Belongs to User and User has One Account

```ruby
class Account < ActiveRecord::Base
  belongs_to :user
end
```

```ruby
class User < ActiveRecord::Base
  # Relationships
  has_one :account
end
```

### Account has many Source Transactions

```ruby
class Account < ActiveRecord::Base
  belongs_to :user
  has_many :source_transactions, class_name: 'Transaction', foreign_key: :source_account_id
end
```

```ruby
class Transaction < ActiveRecord::Base
  belongs_to :source_account, class_name: 'Account'
end
```

### Validations

Validations are used to ensure that only valid data is saved into your database

```ruby
class User < ActiveRecord::Base
  # Relationships
  has_one :account

  # Validations
  validates :name, presence: true
end
```

TODO: Validar que Account tiene balance suficiente al crear una Transacción

### Callbacks

Callbacks allow you to trigger logic before or after a change to an object's state. They are methods that get called at certain moments of an object's life cycle

```ruby
class Transaction < ActiveRecord::Base
  belongs_to :source_account, class_name: 'Account'
  belongs_to :target_account, class_name: 'Account'

  after_create :transfer_balance

  private

  def transfer_balance
    # Hacer todo en una transacción de DB para evitar inconsistencias
    ActiveRecord::Base.transaction do
      source_account.balance -= amount
      source_account.save!

      target_account.balance += amount
      target_account.save!
    end
  end
end
```

## References

- [Active Record](https://github.com/rails/rails/tree/main/activerecord)
- [Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
- [Active Record Validations](https://guides.rubyonrails.org/active_record_validations.html)
- [Active Record Callbacks](https://guides.rubyonrails.org/active_record_callbacks.html)
