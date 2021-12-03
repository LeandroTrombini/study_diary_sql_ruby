require_relative 'category'
require 'sqlite3'

class StudyItem
    attr_accessor :title, :category, :descr, :id, :done
    def initialize(id: nil, title:, category:, descr:, done: false, created_at: nil)
        @id = id
        @title = title
        @category = category
        @descr = descr
        @done = done
        @created_at = created_at
    end
    

    def to_s 
        "#{id} - #{title} - #{category} - #{descr}#{done == 1 ? ' - Concluído' : ' - Em andamento'}"
    end

    def include?(term)
        title.downcase.include? term.downcase 
    end

    def self.create
        print 'Digite um item para estudo: '
        title = gets.chomp
        print "=========================\n"
        print_collection(Category.all_categories)
        puts
        print 'Escolha uma categoria: '
        category = Category.index(gets.to_i - 1)
        print 'Digite uma descrição para o item de estudo: '
        descr = gets.chomp
        puts
        puts "'#{title}' da catergoria '#{category}' - Descrição: '#{descr}' cadastrado com sucesso!"
        StudyItem.new(title: title, category: category, descr: descr)
        db = SQLite3::Database.open 'db/database.db'
        db.execute(<<~SQL, title, category.to_s, descr, 0)
            INSERT INTO study_items (title, category, descr, done)
            VALUES (?, ?, ?, ?)
        SQL
    ensure
        db.close if db
    end

    def self.all
        db = SQLite3::Database.open 'db/database.db'
        db.results_as_hash = true
        results = db.execute("SELECT * FROM study_items")
        results
            .map { |hash| hash.transform_keys!(&:to_sym) }
            .map { |item| StudyItem.new(**item) }      
    ensure
        db.close if db
    end

    def self.delete_by_id(id)
        db = SQLite3::Database.open "db/database.db"
        db.results_as_hash = true
        study_items = db.execute "DELETE FROM study_items WHERE id=#{id}"
    ensure
        db.close if db
    end

    def self.search(title)
        db = SQLite3::Database.open "db/database.db"
        db.results_as_hash = true
        study_items = db.execute "SELECT id, title, category, descr, done FROM study_items where (title LIKE'%#{title}%' OR descr LIKE'%#{title}%')"        
        if study_items.length == 0
          return print "Não foi encontrado nenhum item."
        else
          print "Resultado da busca: "
          puts
          study_items
          .map {|hash| hash.transform_keys!(&:to_sym)}
          .map {|study_item| new(**study_item)}    
        end
    ensure
         db.close if db
    end

    def self.not_concluded
        db = SQLite3::Database.open "db/database.db"
        db.results_as_hash = true
        study_items = db.execute "SELECT * FROM study_items WHERE done=0"
        study_items
          .map {|hash| hash.transform_keys!(&:to_sym)}
          .map {|study_item| new(**study_item)}
      ensure
        db.close if db
    end    

    def self.done(id)
        db = SQLite3::Database.open "db/database.db"
        db.results_as_hash = true
        study_items = db.execute "UPDATE study_items SET done=1  WHERE id=#{id}"
    ensure
        db.close if db            
    end

    def self.search_by_category(term)
        db = SQLite3::Database.open "db/database.db"
        db.results_as_hash = true
        study_items = db.execute "SELECT * FROM study_items WHERE category LIKE '%#{term}%'"
        study_items
          .map {|hash| hash.transform_keys!(&:to_sym)}
          .map {|study_item| new(**study_item)}
      ensure
        db.close if db
      end
    
end