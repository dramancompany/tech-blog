require 'fileutils'
require 'securerandom'

# 특정 폴더 경로 설정
images_folder_path = './images'  # 여러분의 이미지 폴더 경로로 변경하세요
md_folder_path = './_posts'  # Markdown 파일이 있는 폴더 경로

# 난수화된 이름 생성 함수
def generate_random_filename(length = 10)
  SecureRandom.alphanumeric(length)
end

# 이미지 파일명을 난수화된 형식으로 변경하는 함수
def randomize_image_filenames(images_folder_path, md_folder_path)
  # 이미지 파일명을 난수화하고, 파일 이름 매핑 저장
  filename_mapping = {}

  Dir.glob("#{images_folder_path}/**/*.{png,jpg,jpeg,gif}") do |file_path|
    file_name = File.basename(file_path).unicode_normalize
    extension = File.extname(file_name)
    random_name = generate_random_filename + extension
    randomized_path = File.join(File.dirname(file_path), random_name)

    # 파일명 변경
    # debug_find_file_name = '스크린샷-2022-04-26-오후-8.09.38-1.png'.unicode_normalize
    # if file_name == debug_find_file_name
    #   puts "Found file: #{file_name}"
    # end
    FileUtils.mv(file_path, randomized_path)

    # 매핑 저장 (원본 경로와 난수화된 파일 이름)
    filename_mapping[file_name] = random_name
  end

  # Markdown 파일의 이미지 경로 업데이트
  Dir.glob("#{md_folder_path}/**/*.md") do |file_path|
    content = File.read(file_path, encoding: 'utf-8').unicode_normalize
    updated_content = content.clone

    # 패턴을 통해 Markdown에서 파일명 추출 후 매핑에서 변경된 파일명 찾기
    pattern = /(!\[.*?\]\()\/images\/(.*?\.(png|jpg|jpeg|gif))/
    content.scan(pattern) do |match|
      original_filename = match[1]
      if filename_mapping.key?(original_filename)
        randomized_filename = filename_mapping[original_filename]
        updated_content.gsub!("/images/#{original_filename}", "/images/#{randomized_filename}")
      end
    end

    # 변경된 내용을 파일에 다시 쓰기 (내용이 변경된 경우에만)
    if updated_content != content
      File.write(file_path, updated_content, encoding: 'utf-8')
      puts "Updated Markdown file: #{file_path}"
    end
  end
end

if __FILE__ == $0
  randomize_image_filenames(images_folder_path, md_folder_path)
end

