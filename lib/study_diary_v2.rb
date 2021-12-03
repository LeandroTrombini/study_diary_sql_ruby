require 'io/console'
require_relative 'study_item'

REGISTER = 1
DELETE = 2
ALL = 3
SEARCH_ITEM = 4
DONE = 5
EXIT = 6

def menu
    puts <<~MENU           
    ========= Menu ==========\n
    [#{REGISTER}] Cadastrar um item para estudo
    [#{DELETE}] Remover um item 
    [#{ALL}] Ver todos os itens cadastrados
    [#{SEARCH_ITEM}] Buscar um item                
    [#{DONE}] Marcar como concluído        
    [#{EXIT}] Sair        
    ========================\n

    MENU
    print 'Escolha uma opção: '
    gets.to_i
end

def print_collection(collection)
        puts collection          
end

def clear
    system 'clear'
end

def keypress
    puts
    puts 'Pressione qualquer tecla para continuar'
    STDIN.getch
end

def wait_and_clear
    keypress
    clear
end

def print_registered(collection)
    print 'Visualizar itens por categoria? (S, N) '
        result = gets.chomp.to_s
        if result.downcase == 's'
            puts 'Digite o nome da categoria que deseja: '
            term = gets.chomp
            puts StudyItem.search_by_category(term)           
        else
            puts
            puts "========= Títulos cadastrados =========="
            puts
            puts collection
            puts ' Nenhum item cadastrado' if collection.empty?            
        end
end

def delete_item
    items = StudyItem.all 
    puts  
    puts items
    puts
    puts "Digite o código do item a ser deletado:"         
        item_para_deletar = gets.to_i

        if item_para_deletar != 0  
          StudyItem.delete_by_id(item_para_deletar)              
          puts "#{item_para_deletar} removido!"
        else
          puts "Código não localizado. Tente novamente."
        end       
end

def search_study_items
    print 'Digite uma palavra para procurar: '
    term = gets.chomp
    StudyItem.search(term)
end

def mark_as_done
    not_concluded = StudyItem.not_concluded
    print_collection(not_concluded)
    return if not_concluded.empty?
  
    print 'Digite o código do item que deseja concluir: '    
    StudyItem.done(gets.to_i)
end

clear
option = menu

loop do
    case option
    when REGISTER
        StudyItem.create    
    when DELETE
        delete_item
    when ALL
        print_registered(StudyItem.all)
    when SEARCH_ITEM
        found_items = search_study_items
        print_collection(found_items)           
    when DONE
        mark_as_done
    when EXIT  
        break
else
    puts 'Opção não encontrada. Tente novamente'      
end 
    wait_and_clear
    clear
    option = menu
end
puts "Você saiu do Diário de Estudos"
